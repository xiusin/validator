module validator

pub struct Max[T] {
pub mut:
	field   FieldData
	message string
	value   string
	data    &T
}

fn (m Max[T]) validate() ! {
	check_value := m.value.int()
	mut message := m.message
	if message.len == 0 {
		message = 'Value must be no greater than {max}.'
	}
	mut block := false
	$for field in T.fields {
		if field.name == m.field.name {
			$if field.typ is string {
				block = m.data.$(field.name).len > check_value
			} $else $if field.typ is int {
				block = m.data.$(field.name) > check_value
			} $else $if field.typ is u32 {
				block = m.data.$(field.name).int() > check_value
			}
		}
	}
	if block {
		return error(message.replace_once('{max}', '${m.value}'))
	}
}
