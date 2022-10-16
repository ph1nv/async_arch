# frozen_string_literal: true

class AccountsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      payload = message.payload
      data = payload['data']
      case [payload['event_name'], payload['event_version']]
      when ['AccountCreated', 1]
        Account.find_or_create_by(public_id: data['public_id']) do |account|
          account.email = data['email']
          account.full_name = data['full_name']
          account.role = data['role']
        end
      when ['AccountUpdated', 1]
        account = Account.find_by(public_id: data['public_id'])
        account.update(full_name: data['full_name'])
      when ['AccountRoleChanged', 1]
        account = Account.find_by(public_id: data['public_id'])
        account.update(role: data['role'])
      end
    end
  end
end
