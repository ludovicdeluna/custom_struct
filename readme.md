
A simple use of inheritance to make custom data structure which force you to
respect the initial hierarchy. Usefull for MongoID object (when you have a
Hash field).


Feel free to inspect code and reuse logic in your app or use a gem for an easier
way.


Usage
-----

Sample code :

```ruby
scope = Ludo::Scope.new(
  publishers: [10, 25, "IKE"],
  cities: ['New York', 'Paris', 'Berlin']
  sizes: ["115x205",{width: 44, height: 152}, {height: 10, width: 100}]
)

#Also be used :
scope.sizes << "18x15"
scope.cities = { include: 1, cities: ['New York','Paris'] }
# Notice that "=" will replace the list, if no present "include" will be true
scope.cities << 'Berlin'
scope.cities.include = false
scope.cities.pop
scope.cities.push 'Berlin'
scope.sizes.pop
# And all other trics you use with standards objects
```

produce :

```json
{
  "cities": {
    "include": true,
    "values": [
      "New York",
      "Paris",
      "Berlin",
      "Chicago"
    ]
  },
  "publishers": [
    "10",
    "25",
    "IKE"
  ],
  "sizes": [
    {
      "width": "115",
      "height": "205"
    },
    {
      "width": "44",
      "height": "152"
    },
    {
      "width": "100",
      "height": "10"
    },
    {
      "width": "18",
      "height": "15"
    }
  ]
}
```

Why this ?
----------
For the fun to make custom data structures who control the input. I use it
in Hash fields with MongoDB to simplify and garanteed the format. No using
simple Hash and control **order** is important when you query your data, because
Mongodb don't show you the same result when order is changed. Here, order
is always preseved.

In this manner, you have a custom object natively compatible with MongoID,
Grape, and any other framework who need hash / json formatted objects.

