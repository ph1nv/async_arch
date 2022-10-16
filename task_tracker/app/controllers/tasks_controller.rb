class TasksController < ApplicationController
  before_action :set_task, only: [:edit, :update]

  def index
    @account = current_account
    @tasks = Task.includes(:account).all
  end

  def new
  end

  def my
    @account = current_account
    @tasks = Task.includes(:account).where(account: current_account)

    render :index
  end

  def create
    employee = Account.find(Account.where(role: 'employee').pluck(:id).sample)
    task = Task.create!(
      description: params[:description],
      jira_id: params[:jira_id],
      account: employee
    )

    event = {
      event_id: SecureRandom.uuid,
      event_version: 2,
      event_time: Time.now.to_s,
      producer: 'auth_service',
      event_name: 'TaskCreated',
      data: {
        public_id: task.public_id,
        description: task.description,
        account_id: task.account.public_id
      }
    }

    result = SchemaRegistry.validate_event(event, 'tasks.created', version: 2)

    if result.success?
      Karafka.producer.produce_async(
        topic: 'tasks',
        payload: event.to_json
      )

      redirect_to :tasks
    else
      # handle error
    end
  end

  def edit
  end

  def update
    task.update(status: params[:status])

    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'auth_service',
      event_name: 'TaskCompleted',
      data: { public_id: task.public_id, account_id: task.account.public_id }
    }

    result = SchemaRegistry.validate_event(event, 'tasks.completed', version: 1)

    if result.success?
      Karafka.producer.produce_async(
        topic: 'tasks',
        payload: event.to_json
      )
    end
  end

  def shuffle
    employees = Account.where(role: 'employee').pluck(:id)
    Task.find_each do |task|
      Task.update!(account_id: employees.sample)

      event = {
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_time: Time.now.to_s,
        producer: 'auth_service',
        event_name: 'TaskAssigned',
        data: {
          public_id: task.public_id,
          description: task.description,
          account_id: task.account.public_id
        }
      }

      result = SchemaRegistry.validate_event(event, 'tasks.assigned', version: 1)

      if result.success?
        Karafka.producer.produce_async(
          topic: 'tasks',
          payload: event.to_json
        )
      end
    end
  end

  private

  def current_account
    @current_account ||= Account.find_by(public_id: session['account']['info']['public_id'])
  end

  def set_account
    @task = Task.find(params[:id])
  end
end
