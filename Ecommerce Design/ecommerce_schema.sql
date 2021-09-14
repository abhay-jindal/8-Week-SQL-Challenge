create database ecommerce;
use ecommerce;

create table product_category (
	id int unsigned not null auto_increment primary key,
    name varchar(50) not null,
    description text,
    parent_id int unsigned,
    foreign key (parent_id) references product_category (id)
);
   
create table product_catalog (
	id int unsigned not null auto_increment primary key,
    name varchar(150) not null,
    sku varchar(150) not null unique,
    barcode varchar(100) unique,
    description text,
    price float not null
);

alter table product_catalog
add column image blob;

create table catalog_category (
	category_id int unsigned not null,
    product_id int unsigned not null,
    primary key (category_id, product_id),
    foreign key (category_id) references product_category(id),
    foreign key (product_id) references product_catalog(id)
);

create table country (
	code char(3) not null primary key, 
	name char(52),
    continent enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America')
);

create table state (
	code char(5) not null primary key, 
	name char(35) not null,
	country_code char(3) not null,
    foreign key (country_code) references country(code)
);

create table user (
	id int unsigned not null primary key auto_increment,
	username char(30) not null unique,
	password char(40) not null,
	first_name char(30) not null,
	last_name char(30) not null,
	phone char(15),
    email varchar(80),
    join_date datetime default CURRENT_TIMESTAMP,
    gender enum('Male', 'Female', 'Other'),
	image blob
);

create table customer (
	id int unsigned primary key not null auto_increment,
	user_id int unsigned not null,
	last_visit datetime,
    birthday date
);

alter table customer
add constraint foreign key (user_id) references user(id);

create table customer_cards (
	card_number int(16) primary key not null unique,
    card_name char(30) not null,
    expiry_month enum('Jan', 'Feb', 'Mar', 'Apr', 'Jun', 'Jul', 'Aug'),
    expiry_year int(4) check (expiry_year between 2021 and 2070),
    customer_id int unsigned not null,
    foreign key (customer_id) references customer(id)
);
    
create table seller (
	id int unsigned primary key not null auto_increment,
	user_id int unsigned not null references user(id),
	status enum('Approved', 'Disapproved', 'Processing'),
    shop_name varchar(60) not null unique,
    website char(50)
);

alter table seller
add constraint foreign key (user_id) references user(id);

create table coupons (
	code char(30) not null primary key,
    seller_id int unsigned not null,
    product_id int unsigned not null,
    discount decimal(5,2) check (discount between 0 and 100) not null,
    description text,
    foreign key (seller_id) references seller(id),
    foreign key (product_id) references product_catalog(id)
);
    
    
create table admin (
	id int unsigned primary key not null auto_increment,
	user_id int unsigned not null references user(id),
	role enum ('Manager', 'CEO', 'DB Admin')
);

alter table admin
add constraint foreign key (user_id) references user(id);

create table address (
	address_id int unsigned not null auto_increment primary key,
	mobile char(15) not null,
    pincode int not null,
    street varchar(255) not null,
    city varchar(50) not null,
    state_code char(5),
    country_code char(3),
    is_primary boolean,
    user_id int unsigned not null,
    foreign key (user_id) references user(id)
);

alter table address
add constraint foreign key (state_code) references state (code),
add constraint foreign key (country_code) references country (code);

create table catalog_seller (
	seller_id int unsigned not null,
    product_id int unsigned not null,
    primary key (seller_id, product_id),
    foreign key (seller_id) references seller(id),
    foreign key (product_id) references product_catalog(id)
);

create table product_reviews (
	id int unsigned not null primary key auto_increment,
    customer_id int unsigned not null,
    product_id int unsigned not null,
    description text,
    create_date datetime default CURRENT_TIMESTAMP,
    star int check (star between 1 and 5) not null,
    foreign key (customer_id) references customer(id),
    foreign key (product_id) references product_catalog(id)
);
    
create table warehouse (
	code char(8) not null unique primary key,
    name varchar(50) not null,
    mobile char(15) not null,
    pincode int not null,
    street varchar(255) not null,
    city varchar(50) not null,
    state_code char(5),
    country_code char(3),
	foreign key (state_code) references state (code),
	foreign key (country_code) references country (code)
);

create table catalog_seller_warehouse (
	product_id int unsigned not null,
    seller_id int unsigned not null,
    warehouse_code char(8) not null,
    product_qty int not null,
    primary key catalog_warehouse_pk (product_id, warehouse_code, seller_id),
    foreign key (product_id) references product_catalog (id),
    foreign key (warehouse_code) references warehouse (code),
    foreign key (seller_id) references seller (id)
 );
 
 create table customer_support (
	id int unsigned not null primary key auto_increment,
    user_id int unsigned not null,
	issue text,
    create_date datetime default current_timestamp,
    foreign key (user_id) references user(id)
);


    
    
 



create table sales_order (
	id int unsigned not null auto_increment primary key,
    order_date date,
    customer_id int unsigned not null,
    foreign key (customer_id) references customer(id),
    total_amount int not null
);

create table order_items (
	id int unsigned not null auto_increment primary key,
	order_id int not null,
    product_id int unsigned not null,
    item_qty int not null,
    price float not null,
    discount_price float not null,
    coupon_code char(30) not null,
    foreign key (order_id) references sales_order(id),
    foreign key (coupon_code) references coupons(code),
    foreign key (product_id) references product_catalog(id)
);

create table sales_invoice (
	id int unsigned not null auto_increment primary key,
    invoice_date date,
    order_id int not null,
    total_amount float,
    status enum('Paid', 'Processing', 'New'),
    foreign key(order_id) references sales_order(id)
);

create table invoice_items (
	id int unsigned not null auto_increment primary key,
	invoice_id int unsigned not null,
    order_line_id int unsigned not null,
    item_qty int not null,
    price float not null,
    foreign key (invoice_id) references sales_invoice(id),
    foreign key (order_line_id) references order_items(id)
);

create table transaction_history (
	id int unsigned not null auto_increment primary key,
    amount float not null,
    create_date datetime default current_timestamp,
    invoice_line_id int unsigned not null,
    foreign key (invoice_line_id) references invoice_items(id)
);

create table shipping_carrier (
	code char(8) not null primary key,
    name varchar(50) not null
);

create table sales_shipment (
	id int unsigned not null primary key auto_increment,
    carrier_code char(8) not null ,
    ship_date datetime default current_timestamp,
    ship_rate float not null,
    status enum('Shipped', 'Processing', 'Complete'),
    foreign key (carrier_code) references shipping_carrier(code)
);
	
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    


    
    



