class DatabasesController < ApplicationController

  def index
    @databs = Database.all
    @datab = Database.new
  end

  def show
    @datab = Database.find params[:id]
  end

  def edit
    @datab = Database.find params[:id]
  end

  def create
    Database.create! params[:datab]
    flash[:notice] = "Database #{params[:datab][:name]} was successfully created."
  rescue StandardError => e
    flash[:notice] = e.to_s
  ensure
    redirect_to databs_path
  end

  def destroy
    Database.destroy! params[:id]
    flash[:notice] = "Database #{params[:id]} was successfully deleted."
  rescue StandardError => e
    flash[:notice] = e.to_s
  ensure
    redirect_to databs_path
  end

end
