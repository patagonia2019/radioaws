class LandsController < ApplicationController
  before_action :set_land, only: [:show, :edit, :update, :destroy]

  # GET /lands
  # GET /lands.json
  def index
    @lands = Land.all
  end

  # GET /lands/1
  # GET /lands/1.json
  def show
  end

  # GET /lands/new
  def new
    @land = Land.new
  end

  # GET /lands/1/edit
  def edit
  end

  # POST /lands
  # POST /lands.json
  def create
    @land = Land.new(land_params)

    respond_to do |format|
      if @land.save
        format.html { redirect_to @land, notice: 'Land was successfully created.' }
        format.json { render :show, status: :created, location: @land }
      else
        format.html { render :new }
        format.json { render json: @land.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lands/1
  # PATCH/PUT /lands/1.json
  def update
    respond_to do |format|
      if @land.update(land_params)
        format.html { redirect_to @land, notice: 'Land was successfully updated.' }
        format.json { render :show, status: :ok, location: @land }
      else
        format.html { render :edit }
        format.json { render json: @land.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lands/1
  # DELETE /lands/1.json
  def destroy
    @land.destroy
    respond_to do |format|
      format.html { redirect_to lands_url, notice: 'Land was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_land
      @land = Land.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def land_params
      params.require(:land).permit(:name)
    end
end
