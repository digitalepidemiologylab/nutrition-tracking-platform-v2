# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: "public" do
    %w[404 422 500].each do |status_code|
      get "/#{status_code}", to: "errors#show", status_code: status_code
    end

    resource :health_check, only: :show

    resources :segmentations, only: [] do
      scope module: :segmentations do
        resource :webhook, only: :create
      end
    end
  end

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "public/home#show"

    scope module: "public" do
      get "/terms", to: "static_pages#terms"
      get "/privacy", to: "static_pages#privacy"
    end

    namespace :participant do
      devise_for :users, skip: %i[sessions registrations], controllers: {
        passwords: "participant/users/passwords"
      }
    end

    # routes for signed in collaborator only
    namespace :collab do
      devise_for :collaborators, singular: :collaborator, controllers: {
        invitations: "collab/collaborators/invitations",
        passwords: "collab/collaborators/passwords",
        sessions: "collab/collaborators/sessions",
        unlocks: "collab/collaborators/unlocks"
      }
      resources :annotations, only: %i[index show] do
        resources :annotation_foods, only: :create
        resources :annotation_products, only: :create
        resources :comments, only: %i[index create]
        resource :confirmation, only: :create, controller: "annotations/confirmations"
        resource :annotation_items_merge_form, only: :create, controller: "annotations/annotation_items_merge_forms"
        resource :annotation_items_destroy_form, only: :destroy, controller: "annotations/annotation_items_destroy_forms"
        resource :opening, only: :create, controller: "annotations/openings"
      end
      resources :annotation_items, only: %i[update destroy] do
        resource :polygon_set, only: %i[update destroy]
        resource :sort, only: :update, controller: "annotation_items/sorts"
      end
      resource :api_documentation, only: %i[] do
        get "/api_v2", to: "api_documentations#api_v2"
        get "/collab_api_v1", to: "api_documentations#collab_api_v1"
      end
      resources :cohorts, only: %i[index show new create edit update] do
        resources :participations, only: %i[index edit update destroy]
        namespace :participations do
          resource :create_form, only: :create
        end
      end
      resources :collaborations, only: %i[edit update] do
        resource :deactivation, only: %i[create destroy], controller: "collaborations/deactivations"
      end
      resources :collaborators, only: :index do
        resources :tokens, only: %i[create destroy], controller: "collaborators/tokens", param: :client
      end
      resources :comment_templates, except: %i[show]
      resources :foods
      resources :food_lists, only: %i[index show edit update destroy]
      resources :food_nutrients, only: %i[new]
      resources :food_sets
      resources :job_logs, only: :index
      resources :participations, only: [] do
        resource :resetter, only: :create, controller: "participations/resetters"
      end
      resources :products, only: %i[index show]
      resource :profile, only: %i[show edit update]
      resources :users, only: %i[index show destroy] do
        resource :anonymizes, only: %i[update], controller: "users/anonymizes"
        resources :intakes, only: %i[index]
        resource :note_forms, only: %i[show edit update]
        resources :participations, only: %i[index]
      end
      namespace :webauthn do
        resources :authentications, only: %i[new create]
        resources :credentials, only: %i[new create destroy]
        resource :challenge, only: :create
        namespace :authentications do
          resource :challenge, only: :create
        end
      end
    end
  end

  namespace :collab do
    namespace :api do
      namespace :v1 do
        mount_devise_token_auth_for "Collaborator", controllers: {}
        devise_scope :collaborator do
          resources :cohorts, only: %i[show] do
            resources :participations, only: %i[index create]
          end
          resources :nutrients, only: %i[index]
          resources :participations, only: %i[show update] do
            resources :annotations, only: :index
          end
        end
      end
    end
  end

  namespace :api do
    namespace :v2 do
      mount_devise_token_auth_for "User", at: "me", controllers: {
        passwords: "api/v2/users/passwords",
        sessions: "api/v2/users/sessions",
        registrations: "api/v2/users/registrations"
      }
      resources :annotations, only: [] do
        resources :comments, only: %i[index create]
      end
      resources :direct_uploads, only: :create
      resources :dishes do
        resources :intakes, only: :create
      end
      resources :dish_forms, only: :create
      resources :intakes, only: %i[index update destroy]
      resource :me, only: %i[show]
      resource :participate, only: :create
      resources :products, only: :index
      resources :push_tokens, only: :create
      resources :participations, only: :index
    end
  end

  authenticated :collaborator do
    mount Lookbook::Engine, at: "/styleguide"
    mount Rswag::Api::Engine => "/api-docs"
  end

  authenticate :collaborator, lambda { |c| c.admin? } do
    mount Coverband::Reporters::Web.new, at: "/coverage"
    mount Sidekiq::Web => "/sidekiq"
  end

  mount LetterOpenerWeb::Engine, at: "/emails" if Rails.env.development?
end
