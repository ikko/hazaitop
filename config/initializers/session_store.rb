# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_k-wiw_session',
  :secret      => '32dd69b244a0e7d6e57d08c90092d6f900c852fb57e668f4238c10af6777f6d7703fe5038d52c4d5d226086c3d8829e0824745a6443dd505493595e22eeca204'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

