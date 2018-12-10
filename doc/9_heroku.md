#### 1. Tworzymy konto na heroku
<https://www.heroku.com/>

#### 2. Ściągamy klienta konsolowego heroku
<https://devcenter.heroku.com/articles/heroku-cli>

Polecane metody instalacji
* Ubuntu
  * używamy snapa
  ```zsh
   $ sudo snap install heroku --classic
  ```
  albo
  * instalujemy z użyciem tarballa
  ```zsh
   $ curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
  ```
* Mac OS
  * ściągamy i instalujemy pkg

    <https://cli-assets.heroku.com/heroku.pkg>

    albo
  * instalujemy przy pomocy `brew` (opcja baaaardzo polecana)
  ```zsh
   $ brew install heroku/brew/heroku
  ```

* Windows
  * Robimy format i instalujemy linuxa, wracamy do punktu 1.


#### 3. Logujemy się w terminalu
```zsh
 $ heroku login
```

#### 4. Dodajemy wersję rubiego na górze do `Gemfile` i gem od postgresqla
```ruby
 # Gemfile

 ruby '2.5.1'

 group :development, :test do
   gem 'sqlite3'
 end

 group :production do
   gem 'pg'
 end
end
```
Instalujemy:
```zsh
  $ bundle install
```
Komitujemy i pushujemy zmiany na branch `master`
#### 5. Tworzymy apkę w kontekście heroku
```zsh
 $ heroku create
```
Deploy kodu na heroku polega na wykonaniu pusha na utworzone dla nas repozytorium. Normalne reporytorium którego używamy do wymieniania kodu powinno byś dostępne pod gitowym remotem o nazwie `origin`. Heroku utworzy sobie drugi remote o nazwie `heroku` którego możemy używać do wrzucania kodu na serwer.

#### 6. Wypuszczamy aplikację na świat
```zsh
 $ git push heroku master
```
Heroku rozpozna po strukturze plików jakiego typu aplikację wrzucamy i na podstawie tego utworzy dla nas poprawną kongifurację serwerową wymaganą do obsłużenia naszej aplikacji

#### 7. Odpalamy migracje
Tak jak lokalnie musimy wykonywać migracje, tak samo produkcyjna baza danych wymaga od nas manualnego wykonywania migracji na serwerze
```zsh
 $ heroku run rails db:migrate
```

#### 8. Odwiedzamy aplikację w przeglądarce
```zsh
 $ heroku open
```

#### 9. Dodatkowe przydatne komendy
Za każdym razem kiedy chcemy uaktualnić kod na serwerze wykonujemy jeszcze raz push mastera na remote `heroku`
Za każdym razem kiedy wyrzucamy na serwer nową migrację musimy pamiętać o wywołaniu migracji na serwerze

Komendy które normalnie odpalamy w konsoli w trakcie developmentu odpalamy na heroku poprzedzając je `heroku run` np.
* Odpalenie migracji
  ````zsh
   $ heroku run rails db:migrate
  ````
* Wejście na produkcyjną konsolę
  ````zsh
   $ heroku run rails console
  ````

Dwie inne przydatne komendy:
* Aby obejrzeć logi serwera
  ````zsh
   $ heroku logs
  ````
* Aby oglądać logi serwera w trybie live
  ````zsh
   $ heroku logs --tail
  ````
* Zmiana nazwy naszej aplikacji (co zmieni też subdomenę w domenie heroku)
  ````zsh
   $ heroku rename <nowa_nazwa_apki>
  ````
