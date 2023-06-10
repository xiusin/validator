module validator

pub interface IValidator {
	field FieldData
	message string
	value string
	validate() !
}

// [head]
// pub struct Validators {
// mut:
// 	validators []IValidator
// }
//
// pub fn new_validators() &Validators {
// 	return &Validators{}
// }
//
// pub fn register_validator[T](validator IValidator) {
// 	mut validator_arr := validators.validators
// 	validator_arr.validators << validator
// }
//
// const validators = new_validators()

// validate data
pub fn validate[T](data &T) ?[]IError {
	mut errs := []IError{}
	mut validators := []IValidator{}

	$for field in T.fields {
		rule_attr := field.attrs.filter(it.contains('validate'))
		mut message_map := map[string]string{}
		if rule_attr.len > 0 {
			mut rules := rule_attr.first().trim_string_left('validate: ').split(',')
			message_attrs := field.attrs.filter(it.contains('message'))
			if message_attrs.len > 0 {
				messages := message_attrs.first().trim_string_left('message: ').split(',')
				for message in messages {
					key, value := message.trim_space().split_once('=')?
					message_map[key] = value
				}
			}

			for mut rule in rules {
				rule = rule.trim_space()
				mut validator := rule
				mut pattern := ''
				if rule.contains('=') {
					validator, pattern = rule.split_once('=') or { rule, '' }
				}
				match validator {
					'min' {
						validators << IValidator(&Min[T]{
							field: field
							message: message_map[validator]
							value: pattern
							data: unsafe { data }
						})
					}
					'max' {
						validators << IValidator(&Max[T]{
							field: field
							message: message_map[validator]
							value: pattern
							data: unsafe { data }
						})
					}
					'required' {
						validators << IValidator(&Required[T]{
							field: field
							message: message_map[validator]
							data: unsafe { data }
						})
					}
					'regexp' {
						validators << IValidator(&Regexp[T]{
							field: field
							message: message_map[validator]
							value: pattern
							data: unsafe { data }
						})
					}
					'number' {
						validators << IValidator(&Number[T]{
							field: field
							message: message_map[validator]
							data: unsafe { data }
						})
					}
					'url' {
						validators << IValidator(&Url[T]{
							field: field
							message: message_map[validator]
							data: unsafe { data }
						})
					}
					else {
						// auto find
					}
				}
			}
		}
	}
	for mut validator in validators {
		validator.validate() or { errs << err }
	}

	return errs
}
