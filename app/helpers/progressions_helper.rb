module ProgressionsHelper

  def pursuit_card_color(tier_name)
    case tier_name
    when 'Exotic'
      'exotic-bcg'
    when 'Legendary'
      'legendary-bcg'
    when 'Rare'
      'rare-bcg'
    when 'Common'
      'common-bcg'
    when 'Uncommon'
      'uncommon-bcg'
    end
  end

  def secods_to_time(total_seconds)
    minutes = ((total_seconds / 60) % 60).round
    hours = (total_seconds / (60 * 60)).round

    "#{hours}:#{minutes}"
  end
end
