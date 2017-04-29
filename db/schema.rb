# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170513133610) do

  create_table "balances", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.integer "jpy", default: 0
    t.integer "btc", default: 0
    t.integer "jpy_reserved", default: 0
    t.integer "btc_reserved", default: 0
    t.integer "jpy_lend_in_use", default: 0
    t.integer "btc_lend_in_use", default: 0
    t.integer "jpy_lent", default: 0
    t.integer "btc_lent", default: 0
    t.integer "jpy_debt", default: 0
    t.integer "btc_debt", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchange_order_rates", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "json_body"
    t.bigint "trade_time_int", unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leverage_balances", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.integer "margin", default: 0
    t.integer "margin_available", default: 0
    t.float "margin_level", limit: 24, default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leverage_positions", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "pair"
    t.string "status"
    t.datetime "closed_at"
    t.decimal "open_rate", precision: 10
    t.decimal "close_rate", precision: 10
    t.decimal "amount", precision: 10
    t.decimal "all_amount", precision: 10
    t.string "side"
    t.decimal "stop_loss_rate", precision: 10
    t.decimal "pl", precision: 10
    t.bigint "user_id", null: false, unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "model_saving_statuses", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "status"
    t.integer "model_number"
    t.bigint "seed_saving_status_id", unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_books", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "json_body"
    t.bigint "trade_time_int", unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rates", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "json_body"
    t.bigint "trade_time_int", unsigned: true
    t.string "pair"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seed_saving_statuses", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickers", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "json_body"
    t.bigint "trade_time_int", unsigned: true
  end

  create_table "trades", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "json_body"
    t.bigint "trade_time_int", unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "api_key"
    t.string "secret_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "start_trade_time", unsigned: true
    t.bigint "last_trade_time", unsigned: true
  end

end
