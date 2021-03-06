class VehiclesController < BelongsToUser
  before_filter :get_vehicle, :except => [:new, :create]
  before_filter :get_select_options, :except => [:destroy]

  def new
    @vehicle = Vehicle.new
    # Set default values
    @vehicle.vehicle_distance_unit = @user.country.vehicle_distance_unit
    @vehicle.vehicle_fuel_unit = @user.country.vehicle_fuel_unit
  end

  def create
    @vehicle = @user.vehicles.create(params[:vehicle])
    if @vehicle.save
      redirect_to user_vehicle_vehicle_fuel_purchases_path(@user, @vehicle)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @vehicle.update_attributes!(params[:vehicle])
    if @vehicle.save
      redirect_to user_vehicle_vehicle_fuel_purchases_path(@user, @vehicle)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to user_accounts_path(@user)
  end

protected

  def get_select_options
    @vehicle_fuel_classes = @user.country.vehicle_fuel_classes.find( :all, :order => 'name')
    @vehicle_fuel_units = VehicleFuelUnit.find( :all, :order => 'name')
    @vehicle_distance_units = VehicleDistanceUnit.find( :all, :order => 'name')
  end

  def get_vehicle
    @vehicle = @user.vehicles.find(params[:id])
  end

end
