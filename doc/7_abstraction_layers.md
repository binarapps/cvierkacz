## 7. Abstraction layers
###### Warstwy abstrakcji

```shell
- Presenters/decorators
- Service objects
- Query objects
- Command objects
```
###### Prezentery/Dekoratory
Opakowują obiekt w dodatkowe metody

```ruby
class Car
  def initialize(production_date)
    @production_date = production_date
  end
end

class CarPresenter < SimpleDelegator
  def production_year
    production_date.year
  end
end

obj = Car.new(Date.new(2018, 9, 10))
car = CarPresenter.new(obj)
car.production_year  #=> 2018
```

###### Service objects
Service objecty nie powinny zapisywać nic w bazie. Zazwyczaj są to kalkulacje.

```ruby
class CalculatePrice
  def initialize(car, coupon, user)
    @car = car
    @coupon = coupon
    @user = user
  end

  def call
    return 'User is a thief!' if user_is_a_thief?
    calculate_price
  end

  private

  def user_is_a_thief?
    @user.thief?
  end

  def calculate_price
    return @car.price unless @coupon
    @car.price - @coupon.amount
  end
end

 price = CalculatePrice.new(car, coupon, user)
 price.call
```

###### Query objects
Pomagają przy skomplikowanych i rozbudowanych query do bazy. Np. gdzie joinujemy kilka tabel, lub robimy szukajkę z filtrami.

```ruby
class SearchCars
  def initialize(filters)
    @filters = filters
    @cars = Car.all
  end

  def call
    return @cars unless @filters
    filter_by_brand
    filter_by_color
    @cars
  end

  private

  def brand_filter
    @cars = @cars.where(brand: @filters[:brand])
  end

  def calculate_price
    @cars = @cars.where(color: @filters[:color])
  end
end

 SearchCars.new(filters).call # => [#<Car: ...>]
```

###### Command objects
Służą do zapisu do bazy danych. Wywołująć command wiemy, że możemy zmienić stan bazy danych. Jako całość zazywczaj odpowiada za jakieś wydarzenie w systemie.

```ruby
class OrderCar
  include ::ActiveModel::Validations

  validates :car, :user, :agreed_price, presence: true

  def initialize(car, agreed_price, user)
    @car = car
    @user = user
    @agreed_price = agreed_price
  end

  def call
    validate! # will raise ActiveModel::ValidationError
    order_car
  end

  private

  def order_car
    # CarOrder is a model
    CarOrder.create(
      car: @car,
      price: @agreed_price,
      user: @user
    )
  end
end

 OrderCar.new(car, agreed_price, user).call # => #<Order: ...>
```

###### Testowanie
Testowanie jest proste i przyjemne. Zważywszy na fakt, że są to zwykłe klasy które można wywołać w każdym miejscu, jedyną komplikacją jest odzwierciedlenie danych wejściowych.

Przykładowe testy:

Test prezentera:
```ruby
#/spec/presenters

RSpec.describe CarPresenter do
  let(:car) { Car.new(Date.new(1989, 1, 2)) ) }

  describe '#production_year' do
    let(:car_presenter) { CarPresenter.new(car) }

    it 'should return production year' do
      expect(car_presenter.production_year).to eq(1989)
    end
  end
end
```

Test serwisu:

```ruby
#/spec/services

RSpec.describe CalculatePrice do
  let!(:car) { create(:car, price: 20_000) }
  let(:user) { create(:user) }
  let(:coupon) { create(:coupon, value: 2_000) }
  let(:service) { CalculatePrice.new(car, coupon, user) }

  describe '#call' do

    it 'should calculate correct price' do
      expect(service.call).to eq(18_000)
    end

    context 'when user is a thief' do
      let(:user) { create(:user, thief: true) }

      it 'should return a message' do
        expect(service.call).to eq('User is a thief!')
      end
    end

    context 'when coupon is not given' do
      let(:coupon) { nil }

      it 'should return the same price from the car' do
        expect(service.call).to eq(20_000)
      end
    end
  end
end
```

Test query:
```ruby
#/spec/queries
RSpec.describe SearchCars do
  let(:query) { SearchCars.new(filters) }

  describe '#call' do
  end
end
```

Text commanda:

```ruby
#/spec/commands

RSpec.describe OrderCar do
  let(:car) { create(:car) }
  let(:agreed_price) { 60_000 }
  let(:user) { user }

  let(:command) { OrderCar.new(car, agreed_price, user) }

  describe '#call' do

    it 'should create OrderCar object' do
      expect{command.call}.to change{Order.count}.by(1)
    end

    it 'should assign correct fields to CarOrder' do
      order = command.call
      expect(order.car).to eq(car)
      expect(order.agreed_price).to eq(agreed_price)
      expect(order.user).to eq(user)
    end

    context 'when car is missing' do
      let(:car) { nil }

      it 'should raise an exception' do
        expect{command.call}.to raise_error(ActiveModel::ValidationError)
      end
    end

    context 'when user is missing' do
      let(:user) { nil }

      it 'should raise an exception' do
        expect{command.call}.to raise_error(ActiveModel::ValidationError)
      end
    end

    context 'when agreed_price is missing' do
      let(:agreed_price) { nil }

      it 'should raise an exception' do
        expect{command.call}.to raise_error(ActiveModel::ValidationError)
      end
    end
  end
end
```
## Work work work work
Wszystkie klasy, które stworzysz powinny mieć pokrycie testowe.

1. Stwórz prezenter dla obiektów `message`. Użyj go aby pod każdym messagem wyświetlić dzień tygodnia kiedy post został opublikowany. Czyli np. `Published on: Monday`. Prezenter powinien zwracać tylko dzień tygodnia. `Published on` powinno znaleźć się w widoku.
2. Stwórz service object, który zwróci strukturę w postaci arraya jsonów dla wszystkich użytkowników w systemie:
```
[
    {
      user: email_usera,
      messages_count: ilosc_message'y,
      comments_count: ilosc_komentarzy
    },
    {
      user: email_usera,
      messages_count: ilosc_message'y,
      comments_count: ilosc_komentarzy
    },
    {...}
]
```
3. Stwórz query object, który zwróci wszystkie message, które mają poniżej 20 znaków. Propozycja nazwania query objectu `ShortMessagesQuery` albo `FetchShortMessages` w folderze `app/queries`.
4. Stwórz command object który będzie odpowiedzialny za stworzenie komentarza. Przenieś walidacje z modelu do commanda. Folder `app/commands`. Dodatkowym krokiem niech będzie wysyłanie emaila do autora message'a że został dodany komentarz.
https://guides.rubyonrails.org/action_mailer_basics.html
Tutaj przykład jak skonfigurować ze skrzynką gmail
https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
5. Spróbuj punkt numer 2 rozwiązać tak by N+1 query problem nie występował.


W przypadku pytań i eksperymentowania w domu piszemy na slacku na kanale `#pomoc`. Zaglądamy tam więc będziemy starali się odpowiadać i poradzać.
