class ContactsController < ApplicationController
  before_action :set_page, only: %i[show]
  before_action :set_file, only: %i[index new]
  before_action :set_data, only: %i[index new ]
  before_action :set_contact, only: %i[index]
  
  CONTACTS_PER_PAGE = 3
  
  def new
    @contact = Contact.new
    @contacts = Contact.all
  end

  def show
    @contacts = Contact.all
    #@contacts = Contact.paginate(page: params[:page])
    @contacts_page = current_user.contacts.offset(@page * CONTACTS_PER_PAGE).limit(CONTACTS_PER_PAGE).order(created_at: :desc)
  end

  def index
    
    respond_to do |format|
      format.html
      format.csv { send_data @contacts.to_csv }
    end
  end

  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      if @contact.save
        format.html { redirect_to contacts_path, notice: 'contact was succesfuly created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def import
    if Contact.import(params[:csv_file])
      redirect_to contacts_path, notice: "data was just imported!, valid #{$franchise} card"
    else
      redirect_to new_contact_path, alert: 'Sorry, No file chosen, Action can not be performed'
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_contact_path, alert: "#{e.message}, it seems your file has duplicated records"
  rescue ActiveModel::UnknownAttributeError => e
    redirect_to new_contact_path, alert: "#{e.message}, it seems your file has invalid records"
  
  end

  private

  def set_page
    @page = params.fetch(:page, 0).to_i
  end 

  def file_params
    @data = params.permit(:csv_file)
    #@data = params.require(:fileupload).permit(:csv_file)
  end

  def set_file
    @csv_file = Fileupload.create(file_params)
    #@file = Fileupload.find_by(params[:id])
    puts '--- setfile--'
    puts @csv_file
    puts' ---*** ---'
  end

  def set_contact
    #@file = Fileupload.find_by(params[:id])
    @contact = Contact.find_by(params[:id])
  end

  def set_data
   
   #@data1 = @csv_file.csv_file.download
   puts '---data---'
   puts @data1
   puts '---***---'
  end

  def contact_params
    params.permit(
      :full_name,
      :date_of_birth,
      :phone_number,
      :address,
      :credit_card,
      :email
    )
  end
end