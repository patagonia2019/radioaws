class ArchiveOrgAudiosController < ApplicationController
  before_action :set_archive_org_audio, only: [:show, :edit, :update, :destroy]

  # GET /archive_org_audios
  # GET /archive_org_audios.json
  def index
    @archive_org_audios = ArchiveOrgAudio.all
  end

  # GET /archive_org_audios/1
  # GET /archive_org_audios/1.json
  def show
  end

  # GET /archive_org_audios/new
  def new
    @archive_org_audio = ArchiveOrgAudio.new
  end

  # GET /archive_org_audios/1/edit
  def edit
  end

  # POST /archive_org_audios
  # POST /archive_org_audios.json
  def create
    @archive_org_audio = ArchiveOrgAudio.new(archive_org_audio_params)

    respond_to do |format|
      if @archive_org_audio.save
        format.html { redirect_to @archive_org_audio, notice: 'Archive org audio was successfully created.' }
        format.json { render :show, status: :created, location: @archive_org_audio }
      else
        format.html { render :new }
        format.json { render json: @archive_org_audio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archive_org_audios/1
  # PATCH/PUT /archive_org_audios/1.json
  def update
    respond_to do |format|
      if @archive_org_audio.update(archive_org_audio_params)
        format.html { redirect_to @archive_org_audio, notice: 'Archive org audio was successfully updated.' }
        format.json { render :show, status: :ok, location: @archive_org_audio }
      else
        format.html { render :edit }
        format.json { render json: @archive_org_audio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archive_org_audios/1
  # DELETE /archive_org_audios/1.json
  def destroy
    @archive_org_audio.destroy
    respond_to do |format|
      format.html { redirect_to archive_org_audios_url, notice: 'Archive org audio was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive_org_audio
      @archive_org_audio = ArchiveOrgAudio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_org_audio_params
      params.require(:archive_org_audio).permit(:identifier, :title, :subtitle, :detail)
    end
end
