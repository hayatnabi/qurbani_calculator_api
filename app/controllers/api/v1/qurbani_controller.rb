class Api::V1::QurbaniController < ApplicationController
  def calculate
    animal_type = params[:animal_type].to_s.downcase
    weight = params[:weight].to_f
    price_per_kg = params[:market_price_per_kg].to_f
    meat_yield_percent = params[:meat_yield_percent].to_f.presence || default_yield(animal_type)

    if animal_type.blank? || weight <= 0 || price_per_kg <= 0 || meat_yield_percent <= 0
      return render json: { error: 'Missing or invalid input' }, status: :bad_request
    end

    estimated_cost = weight * price_per_kg
    estimated_meat_kg = (weight * (meat_yield_percent / 100.0)).round(2)

    meat_distribution_kg = {
      family: (estimated_meat_kg / 3).round(2),
      relatives: (estimated_meat_kg / 3).round(2),
      poor: (estimated_meat_kg / 3).round(2)
    }

    cost_distribution = {
      family: (estimated_cost / 3).round(2),
      relatives: (estimated_cost / 3).round(2),
      poor: (estimated_cost / 3).round(2)
    }

    sharers_allowed = case animal_type
                      when 'cow', 'camel' then 7
                      when 'goat', 'sheep' then 1
                      else 1
                      end

    render json: {
      estimated_cost: estimated_cost.round(2),
      estimated_meat_kg: estimated_meat_kg,
      cost_distribution: cost_distribution,
      meat_distribution_kg: meat_distribution_kg,
      sharers_allowed: sharers_allowed,
      meat_yield_percent_used: meat_yield_percent
    }
  end

  private

  def default_yield(animal_type)
    case animal_type
    when 'cow' then 55
    when 'goat' then 50
    when 'camel' then 60
    else 50
    end
  end
end
