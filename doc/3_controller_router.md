## 1. Wyświetlanie prostego dokumentu HTML jako strony startowej
Tworzymy plik `home_controller.rb` w katalogu `app/controlers`

```ruby
class HomeController < ApplicationController
  def index
  end
end
```

Tworzymy widok `index.html.erb` w katalogu `views/home`


```html
<h1>Cvierkacz</h1>
<p>Yet another messaging app</p>
</hr>
```

Dodajemy ścieżkę strony głównej w `config/routes.rb`

```ruby
Rails.application.routes.draw do
  root 'home#index'
end
```

Odpalamy serwer w terminalu `$ rails s` i odwiedzamy w przeglądarce `http://localhost:3000`

## 2. Wyświetlanie wiadomości

Tworzymy plik `messages_controller.rb` w katalogu `app/controlers`

```ruby
class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def show
    @message = Message.find(params[:id])
  end
end
```

Tworzymy widoki `index.html.erb` i `show.html.erb` w katalogu `views/messages`

```html
## index
<h1>List of all messages</h1>

<table>
  <thead>
    <tr>
      <th>Message</th>
      <th>Author</th>
      <th>Created at</th>
      <th>Updated at</th>
    </tr>
  </thead>
  <tbody>
    <% @messages.each do |message| %>
      <tr>
        <td><%= link_to message.content, message %></td>
        <td><%= message.author %></td>
        <td><%= message.created_at %></td>
        <td><%= message.updated_at %></td>
      </tr>
    <% end%>
  </tbody>
</table>

## show
<h1>Message</h1>

<p><%= @message.content %></p>
<h5>Author: <%= @message.author %></h5>
<h5>Created_at:<%= @message.created_at %></h5>
<h5>Updated at:<%= @message.updated_at %></h5>
</hr>
<%= link_to 'Back to messages', messages_path %>
```

Dodajemy jedną linijką wszystkie ścieżki CRUDowego kontrolera

```ruby
# config/routes.rb

resources :messages
```

W terminalu wpisujemy

```sh
$ rails routes
```

## 3. Usuwanie wiadomości

Dodajemy akcję `destroy` w `messages_controller.rb`

```ruby
# messages_controller.rb

def destroy
  @message = Message.find(params[:id])
  @message.destroy
  redirect_to messages_path
end
```

Dodajemy link w widoku listy wiadomości

```ruby
# views/messages/index.html.erb

<td>
  <%= link_to 'Delete', message, method: :delete %>
</td>
```

## 4. Akcje kontrolera potrzebne do dodawania i edytowania

Dodajemy dwie pary akcji - `new` i `create` oraz `edit` i `update` w `messages_controller.rb`

```ruby
# messages_controller.rb

def new
  @message = Message.new
end

def create
  @message = Message.new(message_params)
  if @message.save
    redirect_to @message
  else
    render :new
  end
end

def edit
  @message = Message.find(params[:id])
end

def update
  @message = Message.find(params[:id])
  if @message.update(message_params)
    redirect_to @message
  else
    render :edit
  end
end
```

Dodajemy metodę prywatną pozwalajacą nam w bezpieczny sposób zarządzać parametrami do tworzenia i edycji

```ruby
# messages_controller.rb

private

def message_params
  params.require(:message).permit(:content, :author)
end
```

## 5. Do zrobienia samodzielnie
1. Zaimplementować pełny CRUDowy RESTowy kontroler dla komentarzy
2. Zaimplementować widoki dla akcji show i index dla komentarzy
3. Dodać komentarze dotyczące wiadomości w akcji show tejże wiadomości
4. Dodać z wyżej wymienionej listy linkowanie do akcji show komentarza
5. Dodać z poziomu akcji show komentarza link do wiadomości której on dotyczy
7. Umożliwić usuwanie komentarzy zarówno z akcji index dla nich jak i z poziomu listy pod wiadomością
8. Przeczytać:
`https://guides.rubyonrails.org/action_controller_overview.html#controller-naming-convention`
`https://guides.rubyonrails.org/action_controller_overview.html#methods-and-actions`
`https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters`
`https://guides.rubyonrails.org/routing.html`
9. Zastanowić się/poczytać jak można by w mądry sposób rozwiązać podczas tworzenia komentarzy łączenie ich z wiadomościami (z punktu widzenia interfejsu użytkownika)

W przypadku pytań i eksperymentowania w domu piszemy na slacku na kanale `#pomoc`. Zaglądamy tam więc będziemy starali się odpowiadać i poradzać.
