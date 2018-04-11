Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  get 'hello' => 'hello#hello'

  get '/', to: 'root#index'

  get  'api/list',   to: 'api#list'
  post 'api/create', to: 'api#create'
  get  'api/detail', to: 'api#detail'
  post 'api/edit',   to: 'api#edit'
  post 'api/finish', to: 'api#finish'
  post 'api/delete', to: 'api#delete'

  # どこにも当てはまらない場合
  get '*path', to: 'application#render_404'
end
