class ContactsController < ApplicationController
  before_action :load_contact

  def show
    @contact = ContactDetail.from(@record)
  end

  def update
    @record.update!(contact_params)
    redirect_to contact_path(@record), notice: "Contact updated."
  end

  private

  def load_contact
    @record = Contact.includes(:conversation).find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name)
  end
end
