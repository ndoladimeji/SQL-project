--QUERY (1)
SELECT DISTINCT
   film_title,
   category_name,
   COUNT(rent_id) OVER (PARTITION BY film_title) AS rental_count 
FROM
   (
      SELECT
         f.title AS film_title,
         c.name AS category_name,
         r.rental_id AS rent_id 
      FROM
         rental r 
         JOIN
            inventory i 
            ON r.inventory_id = i.inventory_id 
         JOIN
            film f 
            ON f.film_id = i.film_id 
         JOIN
            film_category f_c 
            ON f.film_id = f_c.film_id 
         JOIN
            category c 
            ON f_c.category_id = c.category_id 
      WHERE
         c.name IN 
         (
            'Animation',
            'Classics',
            'Comedy',
            'Music',
            'Family',
            'Children'
         )
   )
   sub 
ORDER BY
   category_name,
   film_title;




--QUERY (2)
WITH standard_quartile_CTE (title, name, rental_duration, standard_quartile) AS 
(
   SELECT
      f.title,
      c.name,
      f.rental_duration,
      NTILE(4) OVER (
   ORDER BY
      rental_duration) AS standard_quartile 
   FROM
      film f 
      JOIN
         film_category f_c 
         ON f.film_id = f_c.film_id 
      JOIN
         category c 
         ON f_c.category_id = c.category_id 
)
SELECT
   title,
   name,
   rental_duration,
   standard_quartile 
FROM
   standard_quartile_CTE 
WHERE
   name IN 
   (
      'Family',
      'Classics',
      'Animation',
      'Children',
      'Comedy',
      'Music'
   )
;




--QUERY (3)
SELECT
   DATE_PART('month', rental_date) AS month,
   DATE_PART('year', rental_date) AS year,
   store.store_id,
   COUNT(rental_id) AS rental_count 
FROM
   rental 
   JOIN
      staff 
      ON rental.staff_id = staff.staff_id 
   JOIN
      store 
      ON staff.store_id = store.store_id 
GROUP BY
   1,
   2,
   3 
ORDER BY
   4 DESC;



--QUERY (4)
SELECT
   first_name || '_' || last_name AS full_name,
   DATE_TRUNC('month', payment_date) AS month,
   COUNT(payment_id) AS pay_CountPerMonth,
   SUM(amount) 
FROM
   customer 
   JOIN
      payment 
      ON customer.customer_id = payment.customer_id 
WHERE
   last_name IN 
   (
      SELECT
         last_name 
      FROM
         customer 
         JOIN
            payment 
            ON customer.customer_id = payment.customer_id 
      WHERE
         DATE_PART('year', payment_date) = 2007 
      GROUP BY
         1 
      ORDER BY
         SUM(amount) DESC LIMIT 10
   )
   AND DATE_PART('year', payment_date) = 2007 
GROUP BY
   1,
   2;
