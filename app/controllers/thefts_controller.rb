class TheftsController < ApplicationController
  before_action :set_theft, only: [:show, :edit, :update, :destroy]

  # GET /thefts
  # GET /thefts.json
  def index
    @thefts = Theft.all
  end

  # GET /thefts/1
  # GET /thefts/1.json
  def show
  end

  # GET /thefts/new
  def new
    @theft = Theft.new
  end

  # GET /thefts/1/edit
  def edit
  end

  # POST /thefts
  # POST /thefts.json
  def create
    @theft = Theft.new(theft_params)

    respond_to do |format|
      if @theft.save
        format.html { redirect_to @theft, notice: 'Theft was successfully created.' }
        format.json { render :show, status: :created, location: @theft }
      else
        format.html { render :new }
        format.json { render json: @theft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /thefts/1
  # PATCH/PUT /thefts/1.json
  def update
    respond_to do |format|
      if @theft.update(theft_params)
        format.html { redirect_to @theft, notice: 'Theft was successfully updated.' }
        format.json { render :show, status: :ok, location: @theft }
      else
        format.html { render :edit }
        format.json { render json: @theft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /thefts/1
  # DELETE /thefts/1.json
  def destroy
    @theft.destroy
    respond_to do |format|
      format.html { redirect_to thefts_url, notice: 'Theft was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /run
  # GET /run/1
  def run
    view_context.theftGenerateRadios(@theft)
    respond_to do |format|
      format.html { redirect_to thefts_url, notice: 'Stations were successfully created.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_theft
      @theft = Theft.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def theft_params
      params.require(:theft).permit(:url)
    end
end
