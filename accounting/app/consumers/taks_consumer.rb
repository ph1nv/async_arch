# frozen_string_literal: true

class TaksConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      payload = message.payload
      data = payload['data']
      case [payload['event_name'], payload['event_version']]
      when ['TakCreated', 2]
        account = Account.find_by(public_id: data['account_id'])
        Task.create!(
          public_id: data['public_id'],
          description: data['description'],
          jira_id: data['jira_id'],
          account: account,
          price_for_assign: -rand(10..20),
          price_for_complete: rand(20..40),
        )
        # TODO: substruct from balance
      when ['TaskCompleted', 1]
        task = Task.find_by(public_id: data['public_id'])
        account = Account.find_by(public_id: data['account_id'])
        # TODO: add to balance
      when ['TaskAssigned', 2]
        task = Task.find_by(public_id: data['public_id'])
        account = Account.find_by(public_id: data['account_id'])
        task.update!(account: account)
        # TODO: substruct from balance
      end
    end
  end
end
