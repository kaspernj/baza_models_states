class User < BazaModels::Model
  include BazaModelsStates::Machine

  states initial: :new do
    before_transition :new => :unconfirmed do |user|
      user.send_confirm_mail
    end

    event :preconfirm do
      transition :new => :unconfirmed
    end

    event :confirm do
      transition :new => :confirmed
    end

    event :deactivate do
      transition [:new, :confirmed] => :deactivated
    end
  end

  def send_confirm_mail
    update_attributes!(confirm_mail_sent_at: Time.now)
  end
end
