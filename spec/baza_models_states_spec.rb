require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BazaModelsStates" do
  include DatabaseHelper

  let(:user) { User.create!(email: "test@example.com") }

  it "sets initial state" do
    expect(user.state).to eq "new"
  end

  it "calls callbacks" do
    user.preconfirm
    expect(user.confirm_mail_sent_at).to_not eq nil
  end
end
