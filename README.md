# CFWheels JSON Properties Plugin

The JSON properties plugin allows you to easily add structured data to a single database table field. You can easily store
arrays and structures without the need for extra tables in your model.

The JSON properties plugin has a single initialization method that you must call in your model's `init()`.

## `init` Method

-  jsonProperty
    -  __`property`__ - the model property the serialize and deserialize when interacting with the database.
    -  __`type`__ - possible values include `array` or `struct`.

Once you have initialized your model, there is no extra work required to start using the functionality of this plugin.

## How to Use

Simply add structure data to your JSON property. That's it!

## Interal workings

The JSON proerties plugin works by adding callbacks to the initialized model to transparently serialize/deserialize complex
data types into strings that can be stored in a database.

## Callbacks Added

-  __`$deserializeJSONProperties`__ is called on `aferFind` and `afterSave`
-  __`$serializeJSONProperties`__ is called on `beforeValidation` and `beforeDelete`

## Credits

This plugin was created by [James Gibson](http://iamjamesgibson.com") and is now maintained by
[Chris Peters](http://www.chrisdpeters.com/) with support from [Liquifusion Studios](http://liquifusion.com/).

## License

The MIT License (MIT)

Copyright (c) 2015 Liquifusion Studios
