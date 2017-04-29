Rails.application.routes.draw do
  resource :api, only: [], controller: :api do
    collection do
      # public API
      get :ticker
      get :trades
      get :order_books
      get :exchange_orders_rate, path: :'exchange/orders/rate'
      get :rate_pair, path: :'rate/:pair'

      # private API
      post :exchange_orders , path: :'exchange/orders'
      get :exchange_leverage_positions, path: :'exchange/leverage/positions'
      get :accounts_leverage_balance, path: :'accounts/leverage_balance'

      # トレードデータのセーブ系API
      # seedファイルに保存する
      get :save_seed
      get :check_saving_status
      get :check_saved_seed_time_range
      put :set_user_leverage_balance
      put :set_test_trade_time
      get :check_test_trade_is_over
      put :update_start_trade_time
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
