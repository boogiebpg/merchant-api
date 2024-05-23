# Merchant Test
A couple endpoints to work with transactions, merchant admin panel.

### Project Setup
1. bundle install
2. Insert correct postgres credentials to database.yml.
3. rails db:create
4. rails db:migrate
5. Import example users: bundle exec rake import:users
6. Start server: rails s

### Structure and behavior description
1. There are merchant and admin user roles
2. Merchants has many payment transactions of different types
3. Transactions are related (belongs_to)
We can also have follow/referenced transactions that refer/depend to/on
the initial transaction.
The possible chains are:
Authorize Transaction -> Charge Transaction -> Refund Transaction
Authorize Transaction -> Reversal Transaction
Only approved or refunded transactions can be referenced,
otherwise the submitted transaction will be created with status error
No transactions can be submitted unless the merchant is in active state

### Components
1. Rake task to import new merchants and admins from CSV (import:users)
2. A background Job for deleting transactions older than an hour (cron job)
3. Accepts payments using XML/JSON API (single point POST request)
4. Include API authentication layer (using JWT tokens)
5. Very simple web interface to check existing merchants and transactions: http://localhost:3000

### Presentation:
1. Display, edit, destroy merchants
2. Display transactions

### API usage examples
To be able to use our API we need to create auth key with our first request:

    POST http://localhost:3000/authenticate

Params:
`email: piter@email.com
password: 123`

Response example:
`{
	"auth_token": "NewToken"
}`


Now we can create new transaction:

	POST http://localhost:3000/transactions

Headers:
`Content-Type: application/json
Authorization: Bearer NewToken`

Body:
	`{
		"transaction": {
			"customer_email":"piter@email.com",
			"customer_phone":"84056723",
			"uuid":"ae9479e2-52a6-466b-97a7-98ec06f264e6",
	        "amount":50,
			"status":0,
			"type":"Transaction::Authorize"
		}
	}`

Response:
`
	{
		"transaction": {
			"id": 5,
			"uuid": "ae9479e2-52a6-466b-97a7-98ec06f264e6",
			"amount": "50.0",
			"status": "approved",
			"customer_email": "piter@email.com",
			"customer_phone": "84056723",
			"user_id": 1,
			"transaction_id": null,
			"created_at": "2024-05-23T14:25:46.258Z",
			"updated_at": "2024-05-23T14:25:46.258Z"
		}
	}
`
