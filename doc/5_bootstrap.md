# Podstawy CSS, Bootstrap, Assety

#### 1. Instalacja Bootstrapa w projekcie

Odwiedzamy stronę https://getbootstrap.com/docs/4.1/getting-started/introduction/

Kopiujemy tag <link> podany w QuickStarcie, zawierający zdalny stylesheet Bootstrapa

```html
<link rel="stylesheet"
href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/
css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJ
T3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"
crossorigin="anonymous">
```

Dodajemy też dwa ważne metatagi odpowiedzialne za wyświetlanie strony z odpowiednim kodowaniem i na wszystkich urządzeniach

```html
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
```

I już!

#### 2. Wykorzystanie komponentów bootstrapowych

* Zrozumienie grida - containerów, rowów i column. - https://getbootstrap.com/docs/4.1/layout/grid/

* Poznanie prostych komponentów - https://getbootstrap.com/docs/4.1/components/

#### 3. Navbar

Element będący widoczny na każdej stronie, wizualnie przypięty do góry strony. Zawiera linki do logowania/rejestracji, najczęściej logo aplikacji.
Po zwężeniu strony "kolapsuje" do rozwijalnego przycisku

```html
<nav class="navbar navbar-expand-lg navbar-light
bg-light">
  <a class="navbar-brand" href="#">
    <%= image_tag 'bootstrap-solid.svg', width: 30, height: 30 %>
    Cvierkacz
  </a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarTogglerDemo02" aria-controls="navbarTogglerDemo02" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>

  <div class="collapse navbar-collapse" id="navbarTogglerDemo02">
    <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
      <li class="nav-item active">
      <%= link_to "Home", root_path, class: 'nav-link'%>
      </li>
    </ul>
    <% if user_signed_in? %>
      <span>
        Logged in as
        <strong><%= current_user.email %></strong>.
      </span>
      <%= link_to "Logout", destroy_user_session_path,
      method: :delete,
      class: 'btn btn-outline-warning ml-2' %>
    <% else %>
      <%= link_to "Sign up", new_user_registration_path,
      class: 'btn btn-outline-success
      my-2 my-sm-0 mr-2' %>
      <%= link_to "Login", new_user_session_path,
      class: 'btn btn-outline-success my-2 my-sm-0' %>
    <% end %>
  </div>
</nav>
```

#### 4. Niedziałające rozwijalne menu?

Navbar bootstrapowy korzysta z atrybutów html by uruchomić akcję javascriptową - nie zainstalowaliśmy skryptów bootstrapa, które umożliwiają korzystanie z **interaktywnych** komponentów.

Dodajmy w application.html tagi podane w QuickStarcie

```html
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
```

#### 5. Formularze

W naszych widokach posiadamy już formularz - np. formularz rejestracji. Niestety nie wygląda on póki co zachęcająco.
Zmieńmy to opakowując go w **grid**, a następnie nadając samemu formularzowi i polom odpowiednie klasy.

https://getbootstrap.com/docs/4.1/components/forms/

Póki co pliki widoków Devise'a są dla nas ukryte - wywołując komendę `rails generate devise:views` w terminalu, widoki akcji devise'owych zostaną wygenerowane w naszym folderze `views`. Teraz możemy nadpisać formularz rejestracji.

```html
<div class="container mt-4">
  <div class="row">
    <div class="col-md-6 col-xs-12">
      <h2>Sign up</h2>

      <%= form_for(resource, as: resource_name,
      url: registration_path(resource_name)) do |f| %>
        <%= devise_error_messages! %>

        <div class="form-group">
          <%= f.label :email %><br />
          <%= f.email_field :email,
          autofocus: true, autocomplete: "email",
          class: 'form-control' %>
        </div>

        <div class="form-group">
          <%= f.label :password %>
          <% if @minimum_password_length %>
          <em>(<%= @minimum_password_length %>
          characters minimum)</em>
          <% end %><br />
          <%= f.password_field :password,
          autocomplete: "new-password",
          class: 'form-control' %>
        </div>

        <div class="form-group">
          <%= f.label :password_confirmation %><br />
          <%= f.password_field :password_confirmation,
          autocomplete: "new-password",
          class: 'form-control' %>
        </div>

        <div class="actions">
          <%= f.submit "Sign up",
          class: 'btn btn-primary' %>
        </div>
      <% end %>

      <%= render "devise/shared/links" %>
    </div>
  </div>
</div>
```

#### 6. Alerty

Po pomyślnej rejestracji widzimy alert - sprawmy, by można go było zamknąć ręcznie. - https://getbootstrap.com/docs/4.1/components/alerts/#dismissing

#### 7. Praca samodzielna

1. Używając znanych już klas bootstrapowych i komponentów ostyluj pozostałe formularze w aplikacji
2. Używając grid systemu oraz komponentu **karty** (https://getbootstrap.com/docs/4.1/components/card/) ostyluj listę wiadomości i komentarzy wg własnego uznania.
