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

ActiveRecord::Schema.define(:version => 20131015154545) do

  create_table "amazon_errors", :force => true do |t|
    t.string   "description"
    t.text     "message"
    t.boolean  "retriable"
    t.boolean  "email_user"
    t.boolean  "email_admin"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "error"
  end

  create_table "amazon_payment_accounts", :force => true do |t|
    t.integer  "project_id"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "approvals", :force => true do |t|
    t.integer  "group_id"
    t.integer  "project_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "reason"
    t.string   "status",     :default => "pending", :null => false
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
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
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
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contributions", :force => true do |t|
    t.string   "payment_key"
    t.integer  "amount"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "status",         :default => "none"
    t.integer  "retry_count",    :default => 0
    t.string   "transaction_id"
    t.boolean  "confirmed",      :default => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "groups", :force => true do |t|
    t.string   "name",                 :default => ""
    t.string   "description",          :default => ""
    t.boolean  "open",                 :default => false
    t.integer  "admin_user_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "long_description"
  end

  create_table "groups_projects", :id => false, :force => true do |t|
    t.integer "group_id",   :null => false
    t.integer "project_id", :null => false
  end

  add_index "groups_projects", ["group_id", "project_id"], :name => "index_groups_projects_on_group_id_and_project_id", :unique => true

  create_table "log_cancel_requests", :force => true do |t|
    t.string   "TokenId"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "log_cancel_responses", :force => true do |t|
    t.integer  "log_cancel_request_id"
    t.string   "RequestId"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "log_errors", :force => true do |t|
    t.integer  "log_request_id"
    t.string   "Code"
    t.string   "Message"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "RequestId"
  end

  create_table "log_get_transaction_requests", :force => true do |t|
    t.string   "TransactionId"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "log_get_transaction_responses", :force => true do |t|
    t.string   "TransactionId"
    t.string   "TransactionStatus"
    t.string   "CallerReference"
    t.string   "StatusCode"
    t.string   "StatusMessage"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "log_get_transaction_request_id"
    t.string   "RequestId"
  end

  create_table "log_multi_token_requests", :force => true do |t|
    t.string   "callerReference"
    t.string   "recipientTokenList"
    t.integer  "globalAmountLimit"
    t.string   "paymentReason"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "log_multi_token_responses", :force => true do |t|
    t.string   "tokenID"
    t.string   "status"
    t.string   "errorMessage"
    t.string   "warningCode"
    t.string   "warningMessage"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "log_multi_token_request_id"
  end

  create_table "log_pay_requests", :force => true do |t|
    t.string   "CallerReference"
    t.string   "RecipientTokenId"
    t.string   "SenderTokenId"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "log_pay_responses", :force => true do |t|
    t.string   "TransactionId"
    t.string   "TransactionStatus"
    t.string   "RequestId"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "log_pay_request_id"
  end

  create_table "log_recipient_token_responses", :force => true do |t|
    t.string   "refundTokenID"
    t.string   "tokenID"
    t.string   "status"
    t.string   "callerReference"
    t.string   "errorMessage"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "short_description"
    t.text     "long_description"
    t.integer  "funding_goal"
    t.date     "end_date"
    t.boolean  "active"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "user_id"
    t.boolean  "confirmed"
    t.string   "state"
  end

  create_table "updates", :force => true do |t|
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.integer  "project_id"
    t.boolean  "email_sent"
    t.string   "title"
  end

  create_table "user_actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "object_type"
    t.integer  "object_id"
    t.string   "event"
    t.text     "message"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
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
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.boolean  "admin",                  :default => false
    t.boolean  "starred"
    t.boolean  "blocked",                :default => false
  end

  add_index "users", ["blocked"], :name => "index_users_on_blocked"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "videos", :force => true do |t|
    t.string   "yt_video_id"
    t.boolean  "is_complete", :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "project_id"
    t.boolean  "published",   :default => false
  end

end
