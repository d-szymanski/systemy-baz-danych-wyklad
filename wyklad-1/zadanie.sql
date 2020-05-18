--ZADANIE 1. Korzystając z odpowiedniej tabeli znajdź i określ te zamówienia, które zawierają produkty 
-- o id 2 i 6 (oba jednocześnie). Zadanie rozwiąż na przynajmniej 4 sposoby

--1 - without join
select order_id from order_details od where od.product_id = 2
intersect select order_id from order_details od2 where od2.product_id  = 6
--order_id|
----------|
--   11077|

--2 - inner join
select od.order_id
from order_details od inner join order_details od2 on od.order_id = od2.order_id 
where od.product_id = 2 and od2.product_id = 6
--order_id|
----------|
--   11077|

--3 - inner with different "where"
select od.order_id
from order_details od inner join order_details od2 on od.order_id = od2.order_id 
where od2.product_id = 2 and od.product_id = 6
--order_id|
----------|
--   11077|

--4 outer join
select od.order_id
from order_details od full outer join order_details od2 on od.order_id = od2.order_id 
where od2.product_id = 2 and od.product_id = 6
--order_id|
----------|
--   11077|

--5 left join
select od.order_id
from order_details od left join order_details od2 on od.order_id = od2.order_id 
where od2.product_id = 2 and od.product_id = 6
--order_id|
----------|
--   11077|

--6 right join
select od.order_id
from order_details od right join order_details od2 on od.order_id = od2.order_id 
where od2.product_id = 2 and od.product_id = 6
--order_id|
----------|
--   11077|

--7 inner with "using" instead of on
select od.order_id
from order_details od inner join order_details od2 using(order_id)
where od.product_id = 2 and od2.product_id = 6
--order_id|
----------|
--   11077|

--ZADANIE 2. Wybierz wszystkich klientów, którzy zamówili produkty o id 1 i 5. Zadanie rozwiąż na dwa
-- sposoby. Wynik posortuj po nazwie klienta niemalejąco.

--1 oldschool
select distinct customer_id
from orders o  where o.order_id in(
select od.order_id 
from order_details od inner join order_details od2 on od.order_id = od2.order_id 
where od.product_id = 1 or od2.product_id = 5
)
order by customer_id
-- 37 row(s) fetched - 15ms
--customer_id|
-------------|
--BERGS      |
--BLONP      |
--...

--2 joiny (prawie 2x szybsze query :o )

select distinct customer_id from orders o inner join order_details od using(order_id)
where od.product_id = 1 or od.product_id = 5
order by customer_id
-- 37 row(s) fetched - 7ms
--customer_id|
-------------|
--BERGS      |
--BLONP      |
--...

--3 inny joining
select distinct customer_id from orders o left join order_details od on o.order_id = od.order_id 
where od.product_id = 1 or od.product_id = 5
order by customer_id
-- 37 row(s) fetched - 7ms
--customer_id|
-------------|
--BERGS      |
--BLONP      |
--...

--ZADANIE 3. Stwórz kwerendę, która zwróci nazwę firmy, kraj oraz miasto klientów oraz dostawców z
--powtórzeniami.
select company_name, country , city from customers c
union
select company_name, country , city from suppliers s 
order by company_name 
-- 120 row(s) fetched - 7ms

--ZADANIE 4. Pokaż również firmy, kraj oraz miasto klientów oraz dostawców bez powtórzeń oraz dodaj
-- kolumnę z informacją, kto jest dostawcą, a kto klientem. Wynik posortuj po firmach nierosnąco.

select distinct 'customer' as role, company_name, country , city from customers c
union
select distinct 'suplier' as role, company_name, country , city from suppliers s 
order by company_name desc 
-- 120 row(s) fetched - 7ms

--ZADANIE 5. Wskaż, w których państwach i miastach mają siedziby zarówno klienci, jak i dostawcy.
select distinct country, city from customers 
intersect
select distinct country, city from suppliers 
order by city 
--country|city     |
---------|---------|
--Germany|Berlin   |
--UK     |London   |
--Canada |Montréal |
--France |Paris    |
--Brazil |Sao Paulo|

--ZADANIE 6. Wskaż, w których państwach i miastach mają siedziby dostawcy i klienci, ale nie pracownicy
select distinct country, city from customers
intersect
select distinct country, city from suppliers 
except
select distinct country, city from employees 
order by city 
--country|city     |
---------|---------|
--Germany|Berlin   |
--Canada |Montréal |
--France |Paris    |
--Brazil |Sao Paulo|


--ZADANIE 7. Wskaż, w których państwach i miastach są zarówno klienci i pracownicy, ale nie ma dostawców
select distinct country, city from customers
intersect
select distinct country, city from employees 
except
select distinct country, city from suppliers
order by city 
--country|city    |
---------|--------|
--USA    |Kirkland|
--USA    |Seattle |

--ZADANIE 8. Napisz kwerendę, która sprawdzi i ewentualnie zwróci listę nazwisk, które noszą zarówno klienci, jak i pracownicy.

--to jest XDDD, klienci nie mają tablicy "last_name"
select reverse(substring((reverse(contact_name) || ' ') from 0 for position(' ' in (reverse(contact_name) || ' ')))) AS last_name from customers
intersect
select last_name from employees
--last_name|
-----------|

--ZADANIE 9. Wyświetl nazwy miast, które są miastami wspólnymi dla klientów i pracowników firmy. Wynik posortuj nierosnąco.
select city from customers c
intersect
select city from employees e 
order by city desc
--city    |
----------|
--Seattle |
--London  |
--Kirkland|
