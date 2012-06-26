class SchedulesController < ApplicationController
  before_filter :authenticate_volunteer!

  active_scaffold :schedule do |conf|
    conf.columns = [:day_of_week,:donor,:recipient,:volunteer,:time_start,:time_stop,
                    :irregular,:backup,:transport,:needs_training,:public_notes,
                    :prior_volunteer,:admin_notes]
    conf.columns[:day_of_week].form_ui = :select
    conf.columns[:day_of_week].options = {:options => [["Unknown/varies",nil],["Sunday",0],
                                                       ["Monday",1],["Tuesday",2],["Wednesday",3],
                                                       ["Thursday",4],["Friday",5],["Saturday",6]]}
    conf.columns[:time_start].description = "e.g., 1400"
    conf.columns[:time_stop].description = "e.g., 1600"
    conf.columns[:donor].form_ui = :select
    conf.columns[:volunteer].form_ui = :select
    conf.columns[:recipient].form_ui = :select
    conf.columns[:prior_volunteer].form_ui = :select
    conf.columns[:transport].label = "Mode of Transport"
    conf.columns[:transport].form_ui = :select
    conf.columns[:transport].options = {:options => [["Bike","Bike"],["Car","Car"],["Foot","Foot"]]}
    conf.columns[:irregular].label = "Periodic/Irregular"
    conf.columns[:backup].label = "Backup Pickup"
  end

  # Only admins can change things in the schedule table
  def create_authorized?
    current_volunteer.admin
  end
  def update_authorized?(record=nil)
    current_volunteer.admin
  end
  def delete_authorized?(record=nil)
    current_volunteer.admin
  end

  # Custom views of the index table
  def open
    @conditions = "volunteer_id is NULL"
    index
  end
  def mine
    @conditions = "volunteer_id = '#{current_volunteer.id}'"
    index
  end

  def conditions_for_collection
    @conditions
  end

end 
