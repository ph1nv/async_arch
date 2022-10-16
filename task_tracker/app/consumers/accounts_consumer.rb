# frozen_string_literal: true

class AccountsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      payload = message.payload
      data = payload['data']
      case payload['event_name']
      when 'AccountCreated'
        Account.find_or_create_by(public_id: data['public_id']) do |account|
          account.email = data['email']
          account.full_name = data['full_name']
          account.role = data['role']
        end
      when 'AccountUpdated'
        account = Account.find_by(public_id: data['public_id'])
        account.update(full_name: data['full_name'])
      when 'AccountRoleChanged'
        account = Account.find_by(public_id: data['public_id'])
        account.update(role: data['role'])
      end
    end
  end
end
