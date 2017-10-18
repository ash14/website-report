# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  devise_for :users, path: ''

  root to: 'home#index'

  get 'report', to: 'report#index'
  get 'report/:date', to: 'report#report', constraints: { date: /\d{4}-\d{1,2}-\d{1,2}/ }
  put 'report/upload', to: 'report#upload'

end
