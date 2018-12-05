## 1. ActiveStorage - upload plików

###### Instalacja
Nie musimy nic instalować! :)
Gem jest już zainstalowany i ma swoją konfigurację.

Spójrzmy do pliku `config/storage.yml`. Mamy tam zdefiniowane różne warianty przechowywania plików w aplikacji.
Natomiast w pliku `config/initializers/development.rb` znajdziemy informację, która opcja jest aktualnie wykorzystywana przez nasze środowisko.

```ruby
config.active_storage.service = :local
```

Jedyne co musimy zrobić to uruchomić migracje, które stworzą nam tabele przechowujące informacje o plikach.
```shell
$ bundle exec rails active_storage:install
$ bundle exec rails db:migrate
```

###### Avatar użytkownika
Dodajmy avatar użytkownika. W ten sposób przećwiczymy dodawanie i wyświetlanie plików w aplikacji.

Najpierw zdefinujemy relację Użytkownik <=> Avatar.

```ruby
# models/user.rb

has_one_attached :avatar
```

Następnie, musimy poszukać formularza, w którym będzieli mogli dodać zdjęcie. Skorzystamy w tym przypadku z gemu `devise`.
Devise dostarcza nam widok do edycji danych użytkownika. Stworzymy link żeby móc się do niego dostać.

```html
<!-- app/views/layouts/application.html.erb -->

<!-- Najlepiej obok przycisku Logout  -->
<%= link_to "Edit", edit_user_registration_path, class: 'btn ml-2' %>
```

Po kliknięciu tego linku zobaczymy formularz do edycji użytkownika.
Dodajmy do tego formularza pole na zdjęcie.
```html
<!-- app/views/devise/registrations/edit.html.erb -->

<div class="field">
  <%= f.label :avatar %><br />
  <%= f.file_field :avatar %>
</div>
```

Możemy teraz przetestować naszą pracę (nie bój się, wystarczy przeklikać, nie trzeba pisać testu ;))
Formularz zostaje poprawnie wysłany i dostajemy informację o zapisaniu danych. Sprawdźmy czy nasz avatar się dodał.

```ruby
# rails console

> User.first.avatar.attached?
 => false
```

Dlaczego?... Musimy przepuścić `avatar` jako parametr. Ponieważ całą akcję obsługuje `devise` robimy to troszkę inaczej niż zazwyczaj.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:display_name])
  end
end
```

Sprawdźmy teraz...

Na koniec sprawmy, żeby nasz avatar został wyświetlony w dwóch miejscach: na górnym pasku (wersja 50x50) i w formularzu (wersja 150x150).

```ruby
# Gemfile

gem 'mini_magick'
```

```shell
$ bundle install
```

```html
<!-- app/views/layouts/application.html.erb -->

<!-- Pod "Logged in as" -->
<% if current_user.avatar.attached? %>
  <%= image_tag current_user.avatar.variant(resize: "50x50") %>
<% end %>
```

```html
<!-- app/views/devise/registrations/edit.html.erb -->

<% if current_user.avatar.attached? %>
  <%= image_tag current_user.avatar.variant(resize: "150x150") %>
<% end %>
```

###### Praca własna
1. Zaimplementuj funkcjonalność dodawania obrazka do wiadomości w formularzu dodawania / edycji wiadomości. Pokaż obrazek w widoku `show` oraz w formularzu.
2. Przeczytaj [Active Storage Overview](https://guides.rubyonrails.org/active_storage_overview.html), aby dowiedzieć się o innych możliwościach ActiveStorage.


## 2. Pundit - autoryzacja
Co to jest autoryzacja?
To proces sprawdzenia czy dany użytkownik ma odpowiednie uprawnienia do posługiwania się konkretnymi danymi.
Spróbujmy dostać się do edycji wiadomości, która nie należy do obecnie zalogowanego użytkownika.

###### Instalacja

```ruby
Gemfile

gem 'pundit'
```

```shell
$ bundle install
$ bundle exec rails g pundit:install
```

Zanim stworzymy własną politykę autoryzacji, spójrzmy jak wygląda domyślna polityka `app/policies/application_policy.rb`

###### Autoryzacja edycji wiadomości

Pundit posługuje się metodą `authorize`, żeby sprawdzić czy dany użytkownik ma uprawnienia do konkretnych danych.
Dodajmy autoryzację do akcji `edit`, aby użytkownik mógł edytować tylko te wiadomości, które sam stworzył.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Pundit
end
```

```ruby
# app/controllers/messages_controller.rb

def edit
  @message = Message.find(params[:id])
  authorize(@message)
end
```

Jaki komunikat otrzymamy przy próbie edytowania wiadomości?... Właśnie nie mamy jeszcze klasy odpowiedzialnej za politykę dostępu do wiadomości.

```ruby
# app/policies/message_policy.rb
class MessagePolicy < ApplicationPolicy
  def edit?
    record.user == user
  end
end
```

Teraz przy próbie edycji system zwróci nam stronę błędu. Jednak my chcemy obsłużyć użytkownika w bardziej elegancki sposób. Dodajmy zatem przekierowanie na stronę główną z informacją, że nie wolno mu edytować czyichś wiadomości.

```ruby
# app/controllers/application_controller.rb

rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

private

def user_not_authorized
  flash[:alert] = "Ta wiadomość nie jest twoja!!!"
  redirect_to(request.referrer || root_path)
end
```

###### Praca własna
1. Dodaj autoryzację do akcji `update` i `destroy` w kontrolerze wiadomości.
2. Przeczytaj [Pundit Guide](https://github.com/varvet/pundit) i spróbuj ukryć przyciski "Edit" i "Destroy" dla wiadomości, których aktualny użytkownik nie może edytować i usuwać.


## 3. Kaminari - stronicowanie
Wyobraźmy sobie, że w naszym systemie jest kilka tysięcy wiadomości. Ładowanie wszystkiego naraz i konieczność przewijania zniszczy naszą piękną aplikację. Pozwólmy zatem systemowi stronicować wyniki, a użytkownikowi nawigować łatwo pomiędzy stronami.

###### Instalacja

```ruby
# Gemfile

gem "kaminari"
```

```shell
$ bundle install
```

###### Stronicowanie listy wiadomości
Najpierw ustawimy stronicowanie podczas pobierania wiadomości. `kaminari` doda odpowiednie `scopes` do naszego bazodanowego zapytania.

```ruby
# app/controllers/messages_controller.rb

def index
  @messages = Message.all.page(params[:page])
end
```

Następnie wyrenderujemy linki do kolejnych stron na liście wiadomości.

```html
<!-- app/views/messages/index.html.erb -->

<%= paginate @messages %>
```

Możliwe, że i tak nie widzimy jeszcze stronicowania, ponieważ `kaminari` stronicuje domyślnie po 25 elementów. Można to jednak zmniejszyć.

```ruby
# app/models/Message.rb

paginates_per 3
```

###### Praca własna
1. Przeczytaj [Kaminari Guide](https://github.com/kaminari/kaminari), aby dowiedzieć się o różnych opcjach konfiguracji i wyświetlania stronicowania.

## Podsumowanie pracy własnej:

###### ActiveStorage - upload plików
1. Zaimplementuj funkcjonalność dodawania obrazka do wiadomości w formularzu dodawania / edycji wiadomości. Pokaż obrazek w widoku `show` oraz w formularzu.
2. Przeczytaj [Active Storage Overview](https://guides.rubyonrails.org/active_storage_overview.html), aby dowiedzieć się o innych możliwościach ActiveStorage.

###### Pundit - autoryzacja
1. Dodaj autoryzację do akcji `update` i `destroy` w kontrolerze wiadomości.
2. Przeczytaj [Pundit Guide](https://github.com/varvet/pundit) i spróbuj ukryć przyciski "Edit" i "Destroy" dla wiadomości, których aktualny użytkownik nie może edytować i usuwać.

###### Kaminari - stronicowanie
1. Przeczytaj [Kaminari Guide](https://github.com/kaminari/kaminari), aby dowiedzieć się o różnych opcjach konfiguracji i wyświetlania stronicowania.
