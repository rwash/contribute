# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120402020658) do

  create_table "categories", :force => true do |t|
    t.string   "short_description"
    t.text     "long_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contributions", :force => true do |t|
    t.string   "payment_key"
    t.integer  "amount"
    t.integer  "project_id"
    t.integer  "user_id"
    t.binary   "complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "cancelled"
    t.integer  "waiting_cancellation"
  end

  create_table "log_cancel_requests", :force => true do |t|
    t.string   "TokenId"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_cancel_responses", :force => true do |t|
    t.integer  "log_cancel_request_id"
    t.string   "RequestId"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_errors", :force => true do |t|
    t.integer  "log_request_id"
    t.string   "Code"
    t.string   "Message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "RequestId"
  end

  create_table "log_multi_token_requests", :force => true do |t|
    t.string   "callerReference"
    t.string   "recipientTokenList"
    t.integer  "globalAmountLimit"
    t.string   "paymentReason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_multi_token_responses", :force => true do |t|
    t.string   "tokenID"
    t.string   "status"
    t.string   "errorMessage"
    t.string   "warningCode"
    t.string   "warningMessage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "log_multi_token_request_id"
  end

  create_table "log_pay_requests", :force => true do |t|
    t.string   "CallerReference"
    t.string   "RecipientTokenId"
    t.string   "SenderTokenId"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_pay_responses", :force => true do |t|
    t.string   "TransactionId"
    t.string   "TransactionStatus"
    t.string   "RequestId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "log_pay_request_id"
  end

  create_table "log_recipient_token_responses", :force => true do |t|
    t.string   "refundTokenID"
    t.string   "tokenID"
    t.string   "status"
    t.string   "callerReference"
    t.string   "errorMessage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "short_description"
    t.text     "long_description"
    t.integer  "funding_goal"
    t.date     "end_date"
    t.integer  "category_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "user_id"
    t.string   "payment_account_id"
  end

  create_table "transaction_requests", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "ip_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "card_type"
    t.date     "card_expires_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "contribution_amt"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "name",                   :default => "", :null => false
    t.string   "location"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
