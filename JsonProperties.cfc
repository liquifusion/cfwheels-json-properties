<cfcomponent mixin="model" output="false">
	<cffunction name="init" output="false">
		<cfset this.version = "1.0,1.1,1.4.0,1.4.1,1.4.2">
		<cfreturn this>
	</cffunction>

	<cffunction name="jsonProperty" output="false">
		<cfargument name="property" type="string" required="true" />
		<cfargument name="type" type="string" required="false" default="array" hint="The JSON type may be set to `array` or `struct`. The default is `array`. All other values will be ignored." />
		<cfargument name="registerCallbacks" type="boolean" required="false" default="true" hint="Whether or not this plugin should automatically add the `$deserializeJSONProperties` and `$serializeProperties` callbacks. Set this to false if you want to invoke them or register them yourself.">
		<cfscript>
			var loc = {};
			
			if (!$hasJsonProperties()) {
				variables.wheels.class.jsonProperties = {};
			}

			variables.wheels.class.jsonProperties[arguments.property] = arguments.type;

			if (arguments.registerCallbacks) {
				afterFind(method="$deserializeJSONPropertiesAfterFind");
				afterSave(method="$deserializeJSONProperties");
				beforeValidation(method="$serializeJSONProperties");
				beforeDelete(method="$serializeJSONProperties");
			}
		</cfscript>
	</cffunction>

	<cffunction name="hasChanged" returntype="boolean" output="false">
		<cfscript>
			var loc = {
				returnValue=false,
				coreHasChanged=core.hasChanged,
				wasSerialized=false
			};

			if ($hasJsonProperties()) {
				// Track if property was already serialized.
				for (loc.key in ListToArray(StructKeyList(variables.wheels.class.jsonProperties))) {
					loc.property = this[loc.key];

					if (IsSimpleValue(loc.property) && IsJSON(loc.property)) {
						loc.wasSerialized = true;
						break;
					}
				}

				// No need to serialize again if we're already there.
				if (!loc.wasSerialized) {
					$serializeJSONProperties();
				}
			}

			loc.returnValue = loc.coreHasChanged(argumentCollection=arguments);

			// If properties weren't already serialized, put them back as they were.
			if ($hasJsonProperties() && !loc.wasSerialized) {
				$deserializeJSONProperties();
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$serializeJSONProperties" returntype="boolean" output="false">
		<cfscript>
			var loc = {};

			for (loc.item in variables.wheels.class.jsonProperties) {
				if (!StructKeyExists(this, loc.item)) {
					this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
				}

				if (!IsSimpleValue(this[loc.item])) {
					this[loc.item] = SerializeJSON(this[loc.item]);
				}
			}
		</cfscript>
		<cfreturn true>
	</cffunction>

	<cffunction name="$deserializeJSONProperties" returntype="boolean" output="false">
		<cfscript>
			var loc = {};

			if (this.isInstance()) {
				for (loc.item in variables.wheels.class.jsonProperties) {
					if (!StructKeyExists(this, loc.item)) {
						this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
					}

					if (IsSimpleValue(this[loc.item]) && Len(this[loc.item]) && IsJSON(this[loc.item])) {
						this[loc.item] = DeserializeJSON(this[loc.item]);
					}
					else {
						this[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
					}
				}
			}
		</cfscript>
		<cfreturn true>
	</cffunction>

	<cffunction name="$deserializeJSONPropertiesAfterFind" returntype="struct" output="false">
		<cfscript>
			var loc = {};

			for (loc.item in variables.wheels.class.jsonProperties) {
				if (!StructKeyExists(arguments, loc.item)) {
					arguments[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
				}

				if (IsSimpleValue(arguments[loc.item]) && Len(arguments[loc.item]) && IsJSON(arguments[loc.item])) {
					arguments[loc.item] = DeserializeJSON(arguments[loc.item]);
				}
				else {
					arguments[loc.item] = $setDefaultObject(type=variables.wheels.class.jsonProperties[loc.item]);
				}
			}
		</cfscript>
		<cfreturn arguments>
	</cffunction>

	<cffunction name="$setDefaultObject" output="false">
		<cfargument name="type" type="string" required="true">
		<cfscript>
			var returnObject = [];

			if (arguments.type == "struct") {
				returnObject = {};
			}
		</cfscript>
		<cfreturn returnObject>
	</cffunction>	

	<cffunction name="$isCallingFromCrud" returntype="boolean" output="false">
		<cfscript>
			var loc = {};

			loc.returnValue = false;
			loc.stackTrace = CreateObject("java", "java.lang.Throwable").getStackTrace();

			loc.iEnd = ArrayLen(loc.stackTrace);
			for (loc.i = 1; loc.i lte loc.iEnd; loc.i++) {
				loc.fileName = loc.stackTrace[loc.i].getFileName();

				if (StructKeyExists(loc, "fileName") && !FindNoCase(".java", loc.fileName) && !FindNoCase("<generated>", loc.fileName) && FindNoCase("crud.cfm", loc.fileName)) {
					loc.returnValue = true;
					break;
				}
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<cffunction name="$hasJsonProperties" returntype="boolean" output="false">
		<cfreturn StructKeyExists(variables.wheels.class, "jsonProperties")>
	</cffunction>

	<cffunction name="$convertToString" returntype="string" access="public" output="false">
		<cfargument name="value" type="Any" required="true">
		<cfscript>
			if (IsBinary(arguments.value)) {
				return ToString(arguments.value);
			}
			else if (IsDate(arguments.value)) {
				return CreateDateTime(
					Year(arguments.value),
					Month(arguments.value),
					Day(arguments.value),
					Hour(arguments.value),
					Minute(arguments.value),
					Second(arguments.value)
				);
			}
			else if (IsArray(arguments.value) || IsStruct(arguments.value)) {
				return SerializeJSON(arguments.value);
			}
			else {
				return arguments.value;
			}
		</cfscript>
	</cffunction>
</cfcomponent>