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

ActiveRecord::Schema.define(:version => 20120828135746) do

  create_table "amazon_errors", :force => true do |t|
    t.string   "description"
    t.text     "message"
    t.boolean  "retriable"
    t.boolean  "email_user"
    t.boolean  "email_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "error"
  end

  create_table "approvals", :force => true do |t|
    t.integer  "group_id"
    t.integer  "project_id"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reason"
  end

  create_table "categories", :force => true do |t|
    t.string   "short_description"
    t.text     "long_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type", :default => ""
    t.string   "title",            :default => ""
    t.text     "body"
    t.string   "subject",          :default => ""
    t.integer  "user_id",          :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contributions", :force => true do |t|
    t.string   "payment_key"
    t.integer  "amount"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "retry_count"
    t.string   "transaction_id"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",                 :default => ""
    t.string   "description",          :default => ""
    t.boolean  "open",                 :default => false
    t.integer  "admin_user_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "long_description"
  end

  create_table "groups_projects", :id => false, :force => true do |t|
    t.integer "group_id",   :null => false
    t.integer "project_id", :null => false
  end

  add_index "groups_projects", ["group_id", "project_id"], :name => "index_groups_projects_on_group_id_and_project_id", :unique => true

  create_table "items", :force => true do |t|
    t.integer  "itemable_id",                                :null => false
    t.string   "itemable_type", :limit => 20,                :null => false
    t.integer  "list_id"
    t.integer  "position",                    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["itemable_id", "itemable_type"], :name => "index_items_on_itemable_id_and_itemable_type"

  create_table "lists", :force => true do |t|
    t.string   "kind",                         :default => "default"
    t.integer  "listable_id",                                         :null => false
    t.string   "listable_type",  :limit => 20,                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                        :default => ""
    t.boolean  "show_active",                  :default => true
    t.boolean  "show_funded",                  :default => false
    t.boolean  "show_nonfunded",               :default => false
  end

  add_index "lists", ["listable_id", "listable_type"], :name => "index_lists_on_listable_id_and_listable_type"

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

  create_table "log_get_transaction_requests", :force => true do |t|
    t.string   "TransactionId"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_get_transaction_responses", :force => true do |t|
    t.string   "TransactionId"
    t.string   "TransactionStatus"
    t.string   "CallerReference"
    t.string   "StatusCode"
    t.string   "StatusMessage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "log_get_transaction_request_id"
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
    t.boolean  "confirmed"
    t.string   "state"
    t.integer  "video_id"
  end

  create_table "updates", :force => true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "project_id"
    t.boolean  "email_sent"
    t.string   "title"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "name",                   :default => "",    :null => false
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
    t.boolean  "admin",                  :default => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "yt_video_id"
    t.boolean  "is_complete", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

end
