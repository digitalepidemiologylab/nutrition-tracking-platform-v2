# frozen_string_literal: true

module Barcodes
  class GS1
    PrefixDatum = Struct.new(:lowest, :highest, :countries, :tags, :note, keyword_init: true) do
      def unrestricted_food?
        (%i[restricted non_food] & tags.to_a).empty?
      end
    end

    # Bsearch is used so this MUST be ordered. Gaps are ok.
    # Data source: https://en.wikipedia.org/wiki/List_of_GS1_country_codes
    PREFIX_DATA = [
      PrefixDatum.new(lowest: 0, highest: 0, countries: %w[US], tags: %i[restricted]),
      PrefixDatum.new(lowest: 1, highest: 19, countries: %w[US CA]),
      PrefixDatum.new(lowest: 20, highest: 29, tags: %i[restricted], note: "regional"),
      PrefixDatum.new(lowest: 30, highest: 39, countries: %w[US]),
      PrefixDatum.new(lowest: 40, highest: 49, tags: %i[restricted], note: "member company"),
      PrefixDatum.new(lowest: 50, highest: 59, countries: %w[US]),
      PrefixDatum.new(lowest: 60, highest: 99, countries: %w[US CA]),
      PrefixDatum.new(lowest: 100, highest: 139, countries: %w[US]),
      PrefixDatum.new(lowest: 200, highest: 299, tags: %i[restricted], note: "regional"),
      PrefixDatum.new(lowest: 300, highest: 379, countries: %w[FR MC]),
      PrefixDatum.new(lowest: 380, highest: 380, countries: %w[BG]),
      PrefixDatum.new(lowest: 383, highest: 383, countries: %w[SI]),
      PrefixDatum.new(lowest: 385, highest: 385, countries: %w[HR]),
      PrefixDatum.new(lowest: 387, highest: 387, countries: %w[BA]),
      PrefixDatum.new(lowest: 389, highest: 389, countries: %w[ME]),
      PrefixDatum.new(lowest: 390, highest: 390, countries: %w[XK]),
      PrefixDatum.new(lowest: 400, highest: 440, countries: %w[DE]),
      PrefixDatum.new(lowest: 450, highest: 459, countries: %w[JP]),
      PrefixDatum.new(lowest: 460, highest: 469, countries: %w[RU]),
      PrefixDatum.new(lowest: 470, highest: 470, countries: %w[KG]),
      PrefixDatum.new(lowest: 471, highest: 471, countries: %w[TW]),
      PrefixDatum.new(lowest: 474, highest: 474, countries: %w[EE]),
      PrefixDatum.new(lowest: 475, highest: 475, countries: %w[LV]),
      PrefixDatum.new(lowest: 476, highest: 476, countries: %w[AZ]),
      PrefixDatum.new(lowest: 477, highest: 477, countries: %w[LT]),
      PrefixDatum.new(lowest: 478, highest: 478, countries: %w[UZ]),
      PrefixDatum.new(lowest: 479, highest: 479, countries: %w[LK]),
      PrefixDatum.new(lowest: 480, highest: 480, countries: %w[PH]),
      PrefixDatum.new(lowest: 481, highest: 481, countries: %w[BY]),
      PrefixDatum.new(lowest: 482, highest: 482, countries: %w[UA]),
      PrefixDatum.new(lowest: 483, highest: 483, countries: %w[TM]),
      PrefixDatum.new(lowest: 484, highest: 484, countries: %w[MD]),
      PrefixDatum.new(lowest: 487, highest: 487, countries: %w[KZ]),
      PrefixDatum.new(lowest: 488, highest: 488, countries: %w[TJ]),
      PrefixDatum.new(lowest: 489, highest: 489, countries: %w[HK]),
      PrefixDatum.new(lowest: 490, highest: 499, countries: %w[JP]),
      PrefixDatum.new(lowest: 500, highest: 509, countries: %w[GB]),
      PrefixDatum.new(lowest: 520, highest: 521, countries: %w[GR]),
      PrefixDatum.new(lowest: 528, highest: 528, countries: %w[LB]),
      PrefixDatum.new(lowest: 529, highest: 529, countries: %w[CY]),
      PrefixDatum.new(lowest: 530, highest: 530, countries: %w[AL]),
      PrefixDatum.new(lowest: 531, highest: 531, countries: %w[MK]),
      PrefixDatum.new(lowest: 535, highest: 535, countries: %w[MT]),
      PrefixDatum.new(lowest: 539, highest: 539, countries: %w[IE]),
      PrefixDatum.new(lowest: 540, highest: 549, countries: %w[BE LX]),
      PrefixDatum.new(lowest: 560, highest: 560, countries: %w[PT]),
      PrefixDatum.new(lowest: 569, highest: 569, countries: %w[IS]),
      PrefixDatum.new(lowest: 570, highest: 579, countries: %w[DK FO GL]),
      PrefixDatum.new(lowest: 590, highest: 590, countries: %w[PL]),
      PrefixDatum.new(lowest: 594, highest: 594, countries: %w[RO]),
      PrefixDatum.new(lowest: 599, highest: 599, countries: %w[HU]),
      PrefixDatum.new(lowest: 600, highest: 601, countries: %w[ZA]),
      PrefixDatum.new(lowest: 603, highest: 603, countries: %w[GH]),
      PrefixDatum.new(lowest: 604, highest: 604, countries: %w[SN]),
      PrefixDatum.new(lowest: 608, highest: 608, countries: %w[BH]),
      PrefixDatum.new(lowest: 609, highest: 609, countries: %w[MU]),
      PrefixDatum.new(lowest: 611, highest: 611, countries: %w[MA]),
      PrefixDatum.new(lowest: 613, highest: 613, countries: %w[DZ]),
      PrefixDatum.new(lowest: 615, highest: 615, countries: %w[NG]),
      PrefixDatum.new(lowest: 616, highest: 616, countries: %w[KE]),
      PrefixDatum.new(lowest: 617, highest: 617, countries: %w[CM]),
      PrefixDatum.new(lowest: 618, highest: 618, countries: %w[CI]),
      PrefixDatum.new(lowest: 619, highest: 619, countries: %w[TN]),
      PrefixDatum.new(lowest: 620, highest: 620, countries: %w[TZ]),
      PrefixDatum.new(lowest: 621, highest: 621, countries: %w[SY]),
      PrefixDatum.new(lowest: 622, highest: 622, countries: %w[EG]),
      PrefixDatum.new(lowest: 623, highest: 623, countries: %w[BN]),
      PrefixDatum.new(lowest: 624, highest: 624, countries: %w[LY]),
      PrefixDatum.new(lowest: 625, highest: 625, countries: %w[JO]),
      PrefixDatum.new(lowest: 626, highest: 626, countries: %w[IR]),
      PrefixDatum.new(lowest: 627, highest: 627, countries: %w[KW]),
      PrefixDatum.new(lowest: 628, highest: 628, countries: %w[SA]),
      PrefixDatum.new(lowest: 629, highest: 629, countries: %w[AE]),
      PrefixDatum.new(lowest: 630, highest: 630, countries: %w[QA]),
      PrefixDatum.new(lowest: 631, highest: 631, countries: %w[NA]),
      PrefixDatum.new(lowest: 640, highest: 649, countries: %w[FI]),
      PrefixDatum.new(lowest: 690, highest: 699, countries: %w[CN]),
      PrefixDatum.new(lowest: 700, highest: 709, countries: %w[NO]),
      PrefixDatum.new(lowest: 729, highest: 729, countries: %w[IL]),
      PrefixDatum.new(lowest: 730, highest: 739, countries: %w[SE]),
      PrefixDatum.new(lowest: 740, highest: 740, countries: %w[GT]),
      PrefixDatum.new(lowest: 741, highest: 741, countries: %w[SV]),
      PrefixDatum.new(lowest: 742, highest: 742, countries: %w[HN]),
      PrefixDatum.new(lowest: 743, highest: 743, countries: %w[NI]),
      PrefixDatum.new(lowest: 744, highest: 744, countries: %w[CR]),
      PrefixDatum.new(lowest: 745, highest: 745, countries: %w[PA]),
      PrefixDatum.new(lowest: 746, highest: 746, countries: %w[DO]),
      PrefixDatum.new(lowest: 750, highest: 750, countries: %w[MX]),
      PrefixDatum.new(lowest: 754, highest: 755, countries: %w[CA]),
      PrefixDatum.new(lowest: 759, highest: 759, countries: %w[VE]),
      PrefixDatum.new(lowest: 760, highest: 769, countries: %w[CH LI]),
      PrefixDatum.new(lowest: 770, highest: 771, countries: %w[CO]),
      PrefixDatum.new(lowest: 773, highest: 773, countries: %w[UY]),
      PrefixDatum.new(lowest: 775, highest: 775, countries: %w[PE]),
      PrefixDatum.new(lowest: 777, highest: 777, countries: %w[BO]),
      PrefixDatum.new(lowest: 778, highest: 779, countries: %w[AR]),
      PrefixDatum.new(lowest: 780, highest: 780, countries: %w[CL]),
      PrefixDatum.new(lowest: 784, highest: 784, countries: %w[PY]),
      PrefixDatum.new(lowest: 786, highest: 786, countries: %w[EC]),
      PrefixDatum.new(lowest: 789, highest: 790, countries: %w[BR]),
      PrefixDatum.new(lowest: 800, highest: 839, countries: %w[IT SM VA]),
      PrefixDatum.new(lowest: 840, highest: 849, countries: %w[ES AD]),
      PrefixDatum.new(lowest: 850, highest: 850, countries: %w[CU]),
      PrefixDatum.new(lowest: 858, highest: 858, countries: %w[SK]),
      PrefixDatum.new(lowest: 859, highest: 859, countries: %w[CZ]),
      PrefixDatum.new(lowest: 860, highest: 860, countries: %w[RS]),
      PrefixDatum.new(lowest: 865, highest: 865, countries: %w[MN]),
      PrefixDatum.new(lowest: 867, highest: 867, countries: %w[KP]),
      PrefixDatum.new(lowest: 868, highest: 869, countries: %w[TR]),
      PrefixDatum.new(lowest: 870, highest: 879, countries: %w[NL]),
      PrefixDatum.new(lowest: 880, highest: 880, countries: %w[KR]),
      PrefixDatum.new(lowest: 883, highest: 883, countries: %w[MM]),
      PrefixDatum.new(lowest: 884, highest: 884, countries: %w[KH]),
      PrefixDatum.new(lowest: 885, highest: 885, countries: %w[TH]),
      PrefixDatum.new(lowest: 888, highest: 888, countries: %w[SG]),
      PrefixDatum.new(lowest: 890, highest: 890, countries: %w[IN]),
      PrefixDatum.new(lowest: 893, highest: 893, countries: %w[VN]),
      PrefixDatum.new(lowest: 896, highest: 896, countries: %w[PK]),
      PrefixDatum.new(lowest: 899, highest: 899, countries: %w[ID]),
      PrefixDatum.new(lowest: 900, highest: 919, countries: %w[AT]),
      PrefixDatum.new(lowest: 930, highest: 939, countries: %w[AU]),
      PrefixDatum.new(lowest: 940, highest: 949, countries: %w[NZ]),
      PrefixDatum.new(lowest: 950, highest: 950, note: "GS1 Global special"),
      PrefixDatum.new(lowest: 951, highest: 951, tags: %i[non_food], note: "General Manager Numbers"),
      PrefixDatum.new(lowest: 952, highest: 952, tags: %i[non_food], note: "demonstrations"),
      PrefixDatum.new(lowest: 955, highest: 955, countries: %w[MY]),
      PrefixDatum.new(lowest: 958, highest: 958, countries: %w[MO]),
      PrefixDatum.new(lowest: 960, highest: 961, countries: %w[GB], note: "GTIN-8"),
      PrefixDatum.new(lowest: 962, highest: 969, note: "GTIN-8"),
      PrefixDatum.new(lowest: 977, highest: 979, tags: %i[non_food], note: "publications"),
      PrefixDatum.new(lowest: 980, highest: 980, tags: %i[non_food], note: "refund receipts"),
      PrefixDatum.new(lowest: 981, highest: 984, tags: %i[non_food], note: "coupon"),
      PrefixDatum.new(lowest: 990, highest: 999, tags: %i[non_food], note: "coupon")
    ].freeze

    def self.prefix_datum(prefix:)
      return nil if prefix.length != 3

      prefix_number = prefix.to_i
      PREFIX_DATA.detect do |prefix_datum|
        prefix_number.between?(prefix_datum.lowest, prefix_datum.highest)
      end
    end

    # See https://www.gs1.org/services/how-calculate-check-digit-manually
    def self.check_digit(code_without_check_digit:)
      key = code_without_check_digit.to_s
      return nil if key.nil? || [7, 11, 12, 13, 16, 17].exclude?(key.length)

      key.reverse.each_char.with_index(1).inject(0) do |sum, (number, idx)|
        sum - (idx.even? ? number.to_i : number.to_i * 3)
      end % 10
    end
  end
end
