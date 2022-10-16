class AccountsController < ApplicationController
  before_action :set_account, only: [:edit, :update, :destroy]
  before_action :authenticate_account!, except: [:current]
  before_action :doorkeeper_authorize!, only: [:current]

  def index
    @accounts = Account.all
  end

  def edit
  end

  def current
    respond_to do |format|
      format.json { render :json => current_account }
    end
  end

  def update
    respond_to do |format|
      new_role = @account.role != account_params[:role] ? account_params[:role] : nil

      if @account.update(account_params)
        # HOMEWORK 3
        # ----------------------------- produce event -----------------------
        event = {
          event_id: SecureRandom.uuid,
          event_version: 1,
          event_time: Time.now.to_s,
          producer: 'auth_service',
          event_name: 'AccountUpdated',
          data: { public_id: @account.public_id, full_name: @account.full_name }
        }

        result = SchemaRegistry.validate_event(event, 'accounts.updated', version: 1)

        if result.success?
          KAFKA_PRODUCER.produce_sync(topic: 'accounts-stream', payload: event.to_json)
        end

        if new_role
          event = {
            event_id: SecureRandom.uuid,
            event_version: 1,
            event_time: Time.now.to_s,
            producer: 'auth_service',
            event_name: 'AccountRoleChanged',
            data: { public_id: @account.public_id, role: @account.role }
          }

          result = SchemaRegistry.validate_event(event, 'accounts.role_changed', version: 1)

          if result.success?
            KAFKA_PRODUCER.produce_sync(topic: 'accounts', payload: event.to_json)
          end
        end

        # --------------------------------------------------------------------

        format.html { redirect_to root_path, notice: 'Account was successfully updated.' }
        format.json { render :index, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @account.update(active: false) #, disabled_at: Time.now)

    # HOMEWORK 3
    # ----------------------------- produce event -----------------------
    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'auth_service',
      event_name: 'AccountDeleted',
      data: { public_id: @account.public_id }
    }

    result = SchemaRegistry.validate_event(event, 'accounts.deleted', version: 1)

    if result.success?
      KAFKA_PRODUCER.produce_sync(topic: 'accounts-stream', payload: event.to_json)
    end
    # --------------------------------------------------------------------

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:full_name, :role)
  end

  def current_account
    if doorkeeper_token
      Account.find(doorkeeper_token.resource_owner_id)
    else
      super
    end
  end
end
