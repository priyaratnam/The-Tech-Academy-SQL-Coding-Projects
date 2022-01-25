

SELECT * FROM authors


-- spUpdateAuthor
CREATE PROC spUpdateAuthor
@authorID VARCHAR(40),
@lname VARCHAR(40),
@fname VARCHAR(20)
AS
BEGIN

	UPDATE authors

	SET 
		au_lname = @lname, 
		au_fname = @fname

	WHERE 
		authors.au_id = @authorID

END




-- spFindAuthor
CREATE PROC spFindAuthor
@authorID VARCHAR(40)
AS
BEGIN

	SELECT
		*

	FROM
		authors AS AU

	WHERE
		AU.au_id = @authorID

END

EXEC spFindAuthor
@authorID = '899-46-2035'



-- spFindAuthors
CREATE PROC spFindAuthors
@author_lname VARCHAR(40)
AS
BEGIN

	SELECT
		*

	FROM
		authors AS AU

	WHERE
		AU.au_lname LIKE '%' + @author_lname + '%'

END

EXEC spFindAuthors
@author_lname = 'Ringer'




-- Book Title:   Author:   Genre:   Released:   Price:


ALTER PROC spFindBook
@search_term VARCHAR(80),
@year_pub INT,
@cat VARCHAR(12)
AS
BEGIN

    SELECT 
        TI.title AS 'Book Title:',
        CONCAT(AU.au_fname, ' ', AU.au_lname) AS 'Author:',
        TI.[type] AS 'Genre:',
        DATEPART(YEAR, TI.pubdate) AS 'Released:',
        FORMAT(TI.price, 'C') AS 'Price:'

    FROM 
        titles AS TI
        JOIN titleauthor AS TA
        ON TI.title_id = TA.title_id
        JOIN authors AS AU 
        ON AU.au_id = TA.au_id

    WHERE
        ((TI.title LIKE '%' + @search_term + '%') 
        OR 
            (TI.type LIKE '%' + @cat + '%'))
        AND 
            (DATEPART(YEAR, TI.pubdate) = @year_pub)

    ORDER BY
        TI.price DESC

END

-- null is nothing - no info - no data
-- 0 is a value

CREATE PROC spImprovedBookSearch
@aFname varchar(20) = null, -- includes default values
@aLname varchar(40) = null,
@yearPub int = 0, 
@cat char(12) = null,
@titlePart varchar(50) = null

AS BEGIN

	DECLARE @total AS int = 0 -- a variable

	IF (@aFname IS NOT NULL) -- null check
		SET @total += 1

	IF (@aLname IS NOT NULL) -- null check
		SET @total += 1

	IF (@yearPub IS NOT NULL)
		SET @total += 1

	IF (@cat IS NOT NULL)
		SET @total += 1

	IF (@titlePart IS NOT NULL)
		SET @total += 1

    -- condition check
	IF(@total >= 2) -- based on @total
		SELECT 
			ti.title AS 'Book:',
			ti.type AS 'Category:',
			CONCAT(au.au_fname, ' ', au.au_lname) AS 'Author:',
			DATEPART(YEAR, ti.pubdate) AS 'Year Published:'

		FROM dbo.titles AS ti
		
			JOIN dbo.titleauthor AS ta
			ON ti.title_id = ta.title_id
			JOIN dbo.authors AS au
			ON ta.au_id = au.au_id

		WHERE 
			au.au_fname LIKE '%' + @aFname + '%' -- if null it don't matter
			OR au.au_lname LIKE '%' + @aLname + '%'
			OR ti.title LIKE '%' + @titlePart + '%'
			OR ti.type = @cat
			AND DATEPART(YEAR, ti.pubdate) = @yearPub
    -- error message output
	ELSE
		PRINT(CONCAT('Only ', @total, ' search parameter provided, 2 or more required!'))
END


EXEC spImprovedBookSearch
@aFname = 'Charlene', @yearPub = 2021 @aLname = 'Locksley',
@yearPub = 2018, @cat = 'popular_comp',
@titlePart = 'Net'