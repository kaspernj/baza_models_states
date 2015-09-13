module DatabaseHelper
  def self.included(base)
    base.instance_eval do
      before do
        require "baza_models"
        require "#{File.dirname(__FILE__)}/../models/user"

        db_tempfile = Tempfile.new(["baza_models_states", ".sqlite3"])
        @db_path = db_tempfile.path
        db_tempfile.close!

        @db = Baza::Db.new(type: :sqlite3, path: @db_path)

        @db.tables.create(:users, columns: [
          {name: :id, type: :int, autoincr: true, primarykey: true},
          {name: :email, type: :varchar},
          {name: :state, type: :varchar},
          {name: :confirm_mail_sent_at, type: :datetime}
        ],
        indexes: [:email])

        User.db = @db
        User.init_model
      end

      after do
        @db.close
        File.unlink(@db.args.fetch(:path))
      end
    end
  end
end
