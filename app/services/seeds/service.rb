# frozen_string_literal: true

require "factory_bot_rails"
require "faker"
require_relative "food_sets_import_service"

module Seeds
  class Service
    ADMIN_EMAIL = "admin@myfoodrepo.org"
    MANAGER_EMAIL = "manager@myfoodrepo.org"
    ANNOTATOR_EMAIL = "annotator@myfoodrepo.org"

    DEFAULT_PASSWORD = "MyFoodRepoPassword"

    def call(review_app: false)
      PaperTrail.request(whodunnit: "Seeds::Service #{Time.current}") do
        raise "Please Set SEEDING ENV var" unless ENV["SEEDING"]

        seed_countries
        seed_segmentation_clients
        seed_units
        seed_nutrients
        seed_food_sets
        if review_app
          seed_foods_for_review_app
        else
          seed_foods
          seed_food_food_sets
          seed_food_nutrients
          seed_food_portions
        end
        seed_products(limit: 100)
        seed_cohorts
        seed_collaborators
        seed_collaborations
        seed_users
        seed_participations
        seed_dishes(review_app: review_app)
        seed_annotation_items
        seed_comment_templates
        seed_comments
        make_last_food_list_editable
        clear_sidekiq_queues_and_stats
      end
    end

    private def seed_countries
      countries_data = [
        {
          id: "CH",
          name_en: "Switzerland",
          name_fr: "Suisse",
          name_de: "Schweiz"
        },
        {
          id: "US",
          name_en: "USA",
          name_fr: "USA",
          name_de: "USA"
        },
        {
          id: "DE",
          name_en: "Germany",
          name_fr: "Allemagne",
          name_de: "Deutschland"
        }
      ]
      countries_data.each do |country_data|
        Country.create!(country_data)
      end
    end

    private def seed_segmentation_clients
      SegmentationClient.create!(
        name: "AIcrowd swiss-v3.0",
        ml_model: "swiss-v3.0"
      )
    end

    private def seed_units
      Seeds::UnitsImportService.new.call
    end

    private def seed_nutrients
      Seeds::NutrientsImportService.new.call
    end

    private def seed_food_sets
      Seeds::FoodSetsImportService.new.call
      RefreshSearchIndicesService.new(indexable_class: FoodSet).call
    end

    private def seed_foods_for_review_app
      Seeds::FoodsImportService.new.call(limit: 50)
      RefreshSearchIndicesService.new(indexable_class: Food).call
      Food.find_each do |food|
        unit_id = %w[g ml].sample
        portion_quantity = rand(1..30) * 10
        food.update!(unit_id: unit_id, portion_quantity: portion_quantity)
        Nutrient.limit((3..8).to_a.sample).order("RANDOM()").each do |nutrient|
          FactoryBot.create(:food_nutrient, food: food, nutrient: nutrient)
        end
        FoodSet.limit([1, 2].sample).order("RANDOM()").all.map do |food_set|
          FactoryBot.create(:food_food_set, food: food, food_set: food_set)
        end
      end
    end

    private def seed_foods
      Seeds::FoodsImportService.new.call
      RefreshSearchIndicesService.new(indexable_class: Food).call
    end

    private def seed_food_food_sets
      Seeds::FoodFoodSetsImportService.new.call
    end

    private def seed_food_nutrients
      Seeds::FoodNutrientsImportService.new.call
    end

    private def seed_food_portions
      Seeds::FoodPortionsImportService.new.call
    end

    private def seed_products(limit: nil)
      Seeds::ProductsImportService.new.call(limit: limit)
      RefreshSearchIndicesService.new(indexable_class: Product).call
    end

    private def seed_cohorts
      segmentation_client = SegmentationClient.first
      FoodList.find_each do |food_list|
        created_at = Faker::Time.between(from: 5.months.ago, to: Time.current)
        FactoryBot.create(
          :cohort,
          food_lists: [food_list],
          segmentation_client: segmentation_client,
          created_at: created_at,
          updated_at: created_at
        )
      end
    end

    private def seed_collaborators
      FactoryBot.create(
        :collaborator, :no_webauthn_credentials,
        email: ADMIN_EMAIL,
        name: "Admin 1",
        password: DEFAULT_PASSWORD,
        admin: true,
        bypass_pwned_validation: true
      )
      FactoryBot.create(
        :collaborator, :no_webauthn_credentials,
        email: MANAGER_EMAIL,
        name: "Manager 1",
        password: DEFAULT_PASSWORD,
        bypass_pwned_validation: true
      )
      FactoryBot.create(
        :collaborator, :no_webauthn_credentials,
        email: ANNOTATOR_EMAIL,
        name: "Annotator 1",
        password: DEFAULT_PASSWORD,
        bypass_pwned_validation: true
      )
    end

    private def seed_collaborations
      manager = Collaborator.find_by(email: MANAGER_EMAIL)
      annotator = Collaborator.find_by(email: ANNOTATOR_EMAIL)

      Cohort.all.each_with_index do |cohort, index|
        odd = (index % 2 == 1)
        role = odd ? :manager : :annotator
        collaborator = (role == :manager) ? manager : annotator
        FactoryBot.create(
          :collaboration,
          cohort: cohort,
          collaborator: collaborator,
          role: role
        )
      end
    end

    private def seed_users
      10.times do |i|
        created_at = Faker::Time.between(from: 5.days.ago, to: Time.current)
        FactoryBot.create(
          :user,
          email: "user_#{i + 1}@myfoodrepo.org",
          password: DEFAULT_PASSWORD,
          created_at: created_at,
          updated_at: created_at,
          bypass_pwned_validation: true
        )
      end
    end

    private def seed_participations
      User.all.each_with_index do |user, index|
        odd = (index % 2 == 1)
        cohorts = Cohort.all.sample(odd ? 1 : 2)
        cohorts.each_with_index do |cohort, index|
          associated_at = index.zero? ? nil : (index * 50).days.ago
          FactoryBot.create(:participation, cohort: cohort, user: user, associated_at: associated_at)
        end
      end
    end

    private def seed_dishes(review_app: false)
      Participation.find_each do |participation|
        create_dish_with_image(participation: participation)
        create_dish_with_description(participation: participation)
        create_dish_without_image_and_description(participation: participation)
      end
      Annotation.find_each { |annotation| annotation.open_annotation! if annotation.may_open_annotation? }
    end

    private def seed_annotation_items
      AnnotationItem.reset_column_information
      Annotation.find_each.with_index do |annotation, index|
        if annotation.has_image? || annotation.dish.description.present?
          3.times do |i|
            create_annotion_food_item(annotation: annotation, index: i)
          end
        else
          create_annotation_product_item(annotation: annotation)
        end
      end
    end

    private def seed_comment_templates
      Seeds::CommentTemplatesImportService.new.call
    end

    private def seed_comments
      Annotation.annotatable.includes(:dish).find_each.with_index do |annotation, index|
        dish = annotation.dish
        created_at = Faker::Time.between(from: dish.created_at, to: Time.current)
        collaborator = annotation.cohort&.collaborations&.first&.collaborator
        if collaborator
          FactoryBot.create(
            :comment,
            annotation: annotation,
            user: nil,
            collaborator: collaborator,
            created_at: created_at,
            updated_at: created_at
          )
        end
        if index % 2 == 0
          FactoryBot.create(:comment, annotation: annotation, user: dish.user, created_at: created_at, updated_at: created_at)
        end
      end
    end

    private def random_food_quantities(food:)
      kcal_food_nutrient = food.food_nutrients.find_by(nutrient_id: "energy_kcal")
      if kcal_food_nutrient&.per_hundred&.positive?
        min_quantity = food.kcal_min ? (food.kcal_min / kcal_food_nutrient.per_hundred * 100) : 0
        max_quantity = food.kcal_max ? (food.kcal_max / kcal_food_nutrient.per_hundred * 100) : 100
        [min_quantity, max_quantity].sort
      else
        [0, 100]
      end
    end

    private def create_annotion_food_item(annotation:, index: 0)
      food_list = annotation.cohort.food_lists.first
      food = Food.where(food_list: food_list).order("RANDOM()").limit(1).first
      quantities = random_food_quantities(food: food)
      annotation.annotation_items.create!(
        food: food,
        present_quantity: rand(quantities.first..quantities.last).to_i,
        present_unit: Unit.g_and_ml.sample,
        consumed_quantity: rand(quantities.first..quantities.last).to_i,
        consumed_unit: [Unit.g_and_ml].flatten.sample,
        polygon_set: FactoryBot.build(:polygon_set, dish_image: annotation.dish.dish_image),
        color_index: (index % 10)
      )
    end

    private def create_annotation_product_item(annotation:)
      product = Product.order("RANDOM()").limit(1).first
      annotation.annotation_items.create!(
        product: product,
        present_quantity: product.portion_quantity,
        present_unit: product.unit,
        consumed_quantity: [Faker::Number.number(digits: 2), Faker::Number.number(digits: 2), nil].sample,
        consumed_unit: product.unit
      )
    end

    private def create_dish_with_image(participation:)
      user = participation.user
      created_at = Faker::Time.between(from: participation.started_at, to: participation.ended_at || Time.current)
      FactoryBot.create(
        :dish, :with_dish_image,
        user: user,
        created_at: created_at,
        updated_at: created_at,
        dish_image: FactoryBot.build(
          :dish_image,
          created_at: created_at,
          updated_at: created_at
        ),
        annotations: FactoryBot.build_list(
          :annotation, 1,
          participation: participation,
          intakes: FactoryBot.build_list(
            :intake, 3,
            consumed_at: Faker::Time.between(from: participation.started_at, to: participation.ended_at || Time.current)
          )
        )
      )
    end

    private def create_dish_with_description(participation:)
      user = participation.user
      created_at = Faker::Time.between(from: participation.started_at, to: participation.ended_at || Time.current)
      FactoryBot.create(
        :dish, :with_description,
        user: user,
        created_at: created_at,
        updated_at: created_at,
        annotations: FactoryBot.build_list(
          :annotation, 1,
          participation: participation,
          intakes: FactoryBot.build_list(
            :intake, 3,
            consumed_at: Faker::Time.between(from: participation.started_at, to: participation.ended_at || Time.current)
          )
        )
      )
    end

    private def create_dish_without_image_and_description(participation:)
      user = participation.user
      created_at = Faker::Time.between(from: participation.started_at, to: participation.ended_at || Time.current)
      FactoryBot.create(
        :dish,
        user: user,
        created_at: created_at,
        updated_at: created_at,
        annotations: FactoryBot.build_list(
          :annotation, 1,
          created_at: created_at,
          updated_at: created_at,
          participation: participation,
          intakes: FactoryBot.build_list(
            :intake, 3,
            consumed_at: Faker::Time.between(from: participation.started_at, to: participation.ended_at || Time.current)
          )
        )
      )
    end

    private def make_last_food_list_editable
      FoodList.last.update!(editable: true)
    end

    private def clear_sidekiq_queues_and_stats
      Sidekiq::RetrySet.new.clear
      Sidekiq::ScheduledSet.new.clear
      Sidekiq::DeadSet.new.clear
      Sidekiq::Queue.all.each(&:clear) # rubocop:disable Rails/FindEach
      Sidekiq::Stats.new.reset
    end
  end
end
