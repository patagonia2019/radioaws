class ArchivecatalogsController < ApplicationController
  before_action :set_archivecatalog, only: [:show, :edit, :update, :destroy]

  # GET /archivecatalogs
  # GET /archivecatalogs.json
  def index
    @archivecatalogs = Archivecatalog.all
  end

  # GET /archivecatalogs/1
  # GET /archivecatalogs/1.json
  def show
  end

  # GET /archivecatalogs/new
  def new
    @archivecatalog = Archivecatalog.new
  end

  # GET /archivecatalogs/1/edit
  def edit
  end

  # POST /archivecatalogs
  # POST /archivecatalogs.json
  def create
    @archivecatalog = Archivecatalog.new(archivecatalog_params)

    respond_to do |format|
      if @archivecatalog.save
        format.html { redirect_to @archivecatalog, notice: 'Archivecatalog was successfully created.' }
        format.json { render :show, status: :created, location: @archivecatalog }
      else
        format.html { render :new }
        format.json { render json: @archivecatalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archivecatalogs/1
  # PATCH/PUT /archivecatalogs/1.json
  def update
    respond_to do |format|
      if @archivecatalog.update(archivecatalog_params)
        format.html { redirect_to @archivecatalog, notice: 'Archivecatalog was successfully updated.' }
        format.json { render :show, status: :ok, location: @archivecatalog }
      else
        format.html { render :edit }
        format.json { render json: @archivecatalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archivecatalogs/1
  # DELETE /archivecatalogs/1.json
  def destroy
    @archivecatalog.destroy
    respond_to do |format|
      format.html { redirect_to archivecatalogs_url, notice: 'Archivecatalog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archivecatalog
      @archivecatalog = Archivecatalog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archivecatalog_params
      params.require(:archivecatalog).permit(:identifier, :title, :subtitle, :detail)
    end
end
