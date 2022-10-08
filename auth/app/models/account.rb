class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    admin: 'admin',
    manager: 'manager',
    employee: 'employee'
  }

  after_create do
    account = self

    # ----------------------------- produce event -----------------------
    event = {
      event_name: 'AccountCreated',
      data: {
        public_id: account.public_id,
        email: account.email,
        full_name: account.full_name,
        position: account.position
      }
    }
    # Producer.call(event.to_json, topic: 'accounts-stream')
    # --------------------------------------------------------------------
  end
end