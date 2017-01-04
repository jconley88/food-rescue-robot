class RegionAdmin::FoodTypesController < ApplicationController
  before_filter :authenticate_volunteer!
  before_filter :authorize_region_admin!

  def index
    @food_types = available_food_types

    respond_to do |format|
      format.html
      format.json { render json: @food_types.to_json }
    end
  end

  def new
    @food_type         = FoodType.new
    @available_regions = available_regions

    session[:my_return_to] = request.referer
  end

  def create
    @food_type = FoodType.new(params[:food_type])
    authorize! :create, @food_type

    if @food_type.save
      flash[:notice] = "Created successfully."
      unless session[:my_return_to].nil?
        redirect_to session[:my_return_to] 
      else
        redirect_to region_admin_food_types_url
      end
    else
      flash[:notice] = "Didn't save successfully :("
      render :new
    end
  end

  def edit
    @food_type = FoodType.find(params[:id])
    @available_regions = available_regions

    authorize! :update, @food_type

    session[:my_return_to] = request.referer
  end

  def update
    @food_type = FoodType.find(params[:id])

    authorize! :update, @food_type

    if @food_type.update_attributes(params[:food_type])
      flash[:notice] = "Updated Successfully."
      unless session[:my_return_to].nil?
        redirect_to(session[:my_return_to])
      else
        redirect_to region_admin_food_types_url
      end
    else
      flash[:error] = "Update failed :("
      render :edit
    end
  end

  def destroy
    @l = FoodType.find(params[:id])
    authorize! :destroy, @l
    @l.active = false
    @l.save
    redirect_to(request.referrer)
  end

  private

  def available_food_types
    if current_volunteer.super_admin?
      FoodType.active
    else
      FoodType.active.regional(current_volunteer.region_ids)
    end
  end

  def available_regions
    if current_volunteer.super_admin?
      Region.all
    else
      current_volunteer.assignments.collect{ |a| a.admin ? a.region : nil }.compact
    end
  end

  def authorize_region_admin!
    return if region_admin?
    redirect_to root_url, alert: "Unauthorized"
  end

  def region_admin?
    current_volunteer.any_admin?
  end
end
