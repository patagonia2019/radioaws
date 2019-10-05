class DesconciertosController < ApplicationController
  before_action :set_desconcierto, only: [:show, :edit, :update, :destroy]

  # GET /desconciertos
  # GET /desconciertos.json
  def index
    @desconciertos = Desconcierto.all
  end

  # GET /desconciertos/1
  # GET /desconciertos/1.json
  def show
  end

  # GET /desconciertos/new
  def new
    @desconcierto = Desconcierto.new
  end

  # GET /desconciertos/1/edit
  def edit
  end

  # POST /desconciertos
  # POST /desconciertos.json
  def create
    @desconcierto = Desconcierto.new(desconcierto_params)

    respond_to do |format|
      if @desconcierto.save
        format.html { redirect_to @desconcierto, notice: 'Desconcierto was successfully created.' }
        format.json { render :show, status: :created, location: @desconcierto }
      else
        format.html { render :new }
        format.json { render json: @desconcierto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /desconciertos/1
  # PATCH/PUT /desconciertos/1.json
  def update
    respond_to do |format|
      if @desconcierto.update(desconcierto_params)
        format.html { redirect_to @desconcierto, notice: 'Desconcierto was successfully updated.' }
        format.json { render :show, status: :ok, location: @desconcierto }
      else
        format.html { render :edit }
        format.json { render json: @desconcierto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /desconciertos/1
  # DELETE /desconciertos/1.json
  def destroy
    @desconcierto.destroy
    respond_to do |format|
      format.html { redirect_to desconciertos_url, notice: 'Desconcierto was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_desconcierto
      @desconcierto = Desconcierto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def desconcierto_params
      params.require(:desconcierto).permit(:at_date, :url1, :url2, :url3, :obs)
    end
end
