module validator

pub struct Test {
	username string [validate: 'min=3,max=110,regexp=^\d+$']
	age      int    [validate: 'min=0,max=78']
	content  string [validate: 'required']
	number   string [validate: 'number']
	url      string [validate: 'url']
}

fn test_test() {
	test := Test{
		username: 'xiusin name'
		age: 100
		content: ''
		number: '+1000'
		url: 'go1ogle.123'
	}
	errs := validate[Test](test)
	if errs != none {
		println(errs?)
	}
}
