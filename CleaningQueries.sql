/*
Explore the NashvilleHousing dataset
*/

-- show first 20 rows to get an overview of the table structure
SELECT TOP 20 *
FROM NashvilleHousing;

-- show number of rows
SELECT COUNT(*)
FROM NashvilleHousing

-- show list of columns and their data types
EXEC sp_columns NashvilleHousing;

-- show check constraints for each column using system view
SELECT cc.name AS constraint_name, c.name AS column_name, cc.definition
FROM sys.check_constraints cc
INNER JOIN sys.columns c ON cc.parent_column_id = c.column_id AND cc.parent_object_id = c.object_id
WHERE cc.parent_object_id = OBJECT_ID('NashvilleHousing');

-- show default constraints for each column using system view
SELECT dc.name AS constraint_name, c.name AS column_name, dc.definition
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON dc.parent_column_id = c.column_id AND dc.parent_object_id = c.object_id
WHERE dc.parent_object_id = OBJECT_ID('NashvileeHousing');

-- show number of nulls in each column
SELECT
	COUNT(CASE WHEN UniqueID IS NULL THEN 1 END) AS UniqueIDNulls,
	COUNT(CASE WHEN ParcelID IS NULL THEN 1 END) AS ParcelIDNulls,
	COUNT(CASE WHEN LandUse IS NULL THEN 1 END) AS LandUseNulls,
	COUNT(CASE WHEN PropertyAddress IS NULL THEN 1 END) AS PropertyAddressNulls,
	COUNT(CASE WHEN SaleDate IS NULL THEN 1 END) AS SaleDateNulls,
	COUNT(CASE WHEN SalePrice IS NULL THEN 1 END) AS SalePriceNulls,
	COUNT(CASE WHEN LegalReference IS NULL THEN 1 END) AS LegalReferenceNulls,
	COUNT(CASE WHEN SoldAsVacant IS NULL THEN 1 END) AS SoldAsVacantNulls,
	COUNT(CASE WHEN OwnerName IS NULL THEN 1 END) AS OwnerNameNulls,
	COUNT(CASE WHEN OwnerAddress IS NULL THEN 1 END) AS OwnerAddressNulls,
	COUNT(CASE WHEN Acreage IS NULL THEN 1 END) AS AcreageNulls,
	COUNT(CASE WHEN TaxDistrict IS NULL THEN 1 END) AS TaxDistrictNulls,
	COUNT(CASE WHEN LandValue IS NULL THEN 1 END) AS LandValueNulls,
	COUNT(CASE WHEN BuildingValue IS NULL THEN 1 END) AS BuildingValueNulls,
	COUNT(CASE WHEN TotalValue IS NULL THEN 1 END) AS TotalValueNulls,
	COUNT(CASE WHEN YearBuilt IS NULL THEN 1 END) AS YearBuiltNulls,
	COUNT(CASE WHEN Bedrooms IS NULL THEN 1 END) AS BedroomsNulls,
	COUNT(CASE WHEN FullBath IS NULL THEN 1 END) AS FullBathNulls,
	COUNT(CASE WHEN HalfBath IS NULL THEN 1 END) AS HalfBath,
	COUNT(CASE WHEN SaleDateConverted IS NULL THEN 1 END) AS SaleDateConvertedNulls,
	COUNT(CASE WHEN PropertyStreetAddress IS NULL THEN 1 END) AS PropertyStreetAddressNulls,
	COUNT(CASE WHEN OwnerStreetAddress IS NULL THEN 1 END) AS OwnerStreetAddressNulls,
	COUNT(CASE WHEN OwnerTown IS NULL THEN 1 END) AS OwnerTownNulls,
	COUNT(CASE WHEN OwnerState IS NULL THEN 1 END) AS OwnerStateNulls
FROM NashvilleHousing;

-- show summary statistics for date and numeric columns
SELECT MIN(CAST(SaleDate AS Date)) OldestSaleDate, MAX(CAST(SaleDate AS Date)) NewestSaleDate,
	MIN(SalePrice) LowestSalePrice, MAX(SalePrice) HighestSalePrice, AVG(SalePrice) AvgSalePrice,
	MIN(Acreage) MinAcreage, MAX(Acreage) MaxAcreage, AVG(Acreage) AvgAcreage,
	MIN(LandValue) MinLandValue, MAX(LandValue) MaxLandValue, AVG(LandValue) AvgLandValue,
	MIN(BuildingValue) MinBuildingValue, MAX(BuildingValue) MaxBuildingValue, AVG(BuildingValue) AvgBuildingValue,
	MIN(TotalValue) MinTotalValue, MAX(TotalValue) MaxTotalValue, AVG(TotalValue) AvgTotalValue,
	MIN(YearBuilt) MinYearBuilt, MAX(YearBuilt) MaxYearBuilt, AVG(YearBuilt) AvgYearBuilt,
	MIN(Bedrooms) MinBedrooms, MAX(Bedrooms) MaxBedrooms, AVG(Bedrooms) AvgBedrooms,
	MIN(FullBath) MinFullBath, MAX(FullBath) MaxFullBath, AVG(FullBath) AvgFullBath,
	MIN(HalfBath) MinHalfBath, MAX(HalfBath) MaxHalfBath, AVG(HalfBath) AvgHalfBath
FROM NashvilleHousing;

-- use a nested select query to calculate the median YearBuilt
SELECT
    AVG(YearBuilt)
FROM
(
	SELECT
        YearBuilt,
        ROW_NUMBER() OVER (ORDER BY YearBuilt) AS row_num,  -- add a row number to each row
        COUNT(*) OVER() AS total_rows  -- add the total row count to each row 
    FROM
        NashvilleHousing
	WHERE YearBuilt IS NOT NULL
) AS subquery
WHERE
    row_num IN ( (total_rows + 1) / 2, (total_rows + 2) / 2 );


-- show count for each level for UniqueID
SELECT UniqueID, COUNT(UniqueID) AS [LevelCount]
FROM NashvilleHousing
GROUP BY UniqueID
ORDER BY LevelCount DESC;

-- show count for each level for ParcelID
SELECT ParcelID, COUNT(ParcelID) AS [LevelCount]
FROM NashvilleHousing
GROUP BY ParcelID
ORDER BY LevelCount ASC;

-- show count for each level for LandUse
SELECT LandUse, COUNT(LandUse) AS [LevelCount]
FROM NashvilleHousing
GROUP BY LandUse
ORDER BY LevelCount DESC;

-- show count for each level for LandUse
SELECT LandUse, COUNT(LandUse) AS [LevelCount]
FROM NashvilleHousing
GROUP BY LandUse
ORDER BY LevelCount DESC;

-- show count for each level for PropertyAddress
SELECT PropertyAddress, COUNT(PropertyAddress) AS [LevelCount]
FROM NashvilleHousing
GROUP BY PropertyAddress
ORDER BY LevelCount DESC;

-- show count for each level for LegalReference
SELECT LegalReference, COUNT(LegalReference) AS [LevelCount]
FROM NashvilleHousing
GROUP BY LegalReference
ORDER BY LevelCount DESC;

-- show count for each level of SoldAsVacant
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;

-- show count for each level of OwnerName
SELECT OwnerName, COUNT(OwnerName) AS [LevelCount]
FROM NashvilleHousing
GROUP BY OwnerName
ORDER BY LevelCount DESC;

-- show count for each level of OwnerAddress
SELECT OwnerAddress, COUNT(OwnerAddress) AS [LevelCount]
FROM NashvilleHousing
GROUP BY OwnerAddress
ORDER BY LevelCount DESC;

-- show count for each level for TaxDistrict
SELECT TaxDistrict, COUNT(TaxDistrict) AS [LevelCount]
FROM NashvilleHousing
GROUP BY TaxDistrict
ORDER BY LevelCount DESC;

-- Select records which have a ParcelID that appears more than once in the table to obtain a better understanding of how the field relates to address
WITH ParcelIDCount AS
	(SELECT ParcelID, COUNT(ParcelID) AS [LevelCount]
	FROM NashvilleHousing
	GROUP BY ParcelID)
SELECT *
FROM NashvilleHousing
WHERE ParcelID in (SELECT ParcelID FROM ParcelIDCount WHERE LevelCount > 3)
ORDER BY ParcelID;

-- Select records which have a LegalReference that appears more than once in the table to obtain a better understanding of the LegalReference field
WITH LegalReferenceCount AS
	(SELECT LegalReference, COUNT(LegalReference) AS [LevelCount]
	FROM NashvilleHousing
	GROUP BY LegalReference)
SELECT *
FROM NashvilleHousing
WHERE LegalReference in (SELECT LegalReference FROM LegalReferenceCount WHERE LevelCount > 10)
ORDER BY LegalReference;

/*
Clean the NashvilleHousing dataset
*/

/*
Clean SaleDate
*/

-- add new column SaleDateConverted
ALTER TABLE SQLCleaningProject.dbo.NashvilleHousing
ADD SaleDateConverted Date; 

-- update SaleDateConverted column
UPDATE SQLCleaningProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

/*
Handle missing values in PropertyAddress
*/

-- populate null values by obtaining the PropertyAddress by cross-referencing with ParcelID from other rows
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLCleaningProject.dbo.NashvilleHousing a
JOIN SQLCleaningProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

/*
Split out Addresses into separate columns
*/

-- add new columns StreetAddress, Town
ALTER TABLE SQLCleaningProject.dbo.NashvilleHousing
ADD StreetAddress nvarchar(255), Town nvarchar(255);

-- update StreetAddress, Town columns by splitting PropertyAddress around the comma
UPDATE SQLCleaningProject.dbo.NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	Town = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));

-- Rename StreetAddress and Town to PropertyStreetAddress and PropertyTown
sp_rename 'NashvilleHousing.StreetAddress', 'PropertyStreetAddress', 'COLUMN';
sp_rename 'NashvilleHousing.Town', 'PropertyTown', 'COLUMN';

-- add new columns OwnerStreetAddress, OwnerTown, OwnerState
ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress nvarchar(255), OwnerTown nvarchar(255), OwnerState nvarchar(255);

-- update OwnerStreetAddress, OwnerTown columns by splitting OwnerAddress around the comma
UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerTown = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

/*
Change N to No and Y to Yes in SoldAsVacant field
*/

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END;

/*
Remove duplicates pretending unique ID doesn't exist so we need to partiton by multiple columns - IT IS NOT STANDARD PRACTICE TO DELETE DATA FROM THE DATABASE, INSTEAD YOU CAN LEAVE DUPLICATES OUT OF QUERY
*/

-- use a common table expression to partition rows based on chosen values and assign row numbers to each partition - duplicates will have row numbers greater than 1
-- select only row where assigned row number is 1
WITH CTE AS (
	SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) RowNum
FROM NashvilleHousing
)
SELECT *
FROM CTE
WHERE RowNum = 1
ORDER BY ParcelID ASC
GO;

/*
Recode LandUse
*/

-- add new column LandUseRecoded
--ALTER TABLE SQLCleaningProject.dbo.NashvilleHousing
--ADD LandUseRecoded nvarchar(255);

-- Update LandUseRecoded to categorise LandUse into Residential, Commercial, and Land
--UPDATE NashvilleHousing
--SET LandUseRecoded = CASE 
--		WHEN Landuse in ('SINGLE FAMILY',
--						'RESIDENTIAL CONDO', 
--						'VACANT RESIDENTIAL LAND', 
--						'VACANT RES LAND', 
--						'DUPLEX', 
--						'ZERO LOT LINE', 
--						'CONDO',
--						'RESIDENTIAL COMBO/MISC',
--						'TRIPLEX',
--						'QUADPLEX',
--						'CONDOMINIUM OFC  OR OTHER COM CONDO',
--						'MOBILE HOME',
--						'DORMITORY/BOARDING HOUSE',
--						'SPLIT CLASS',
--						'PARSONAGE',
--						'VACANT RESIENTIAL LAND',
--						'VACANT ZONED MULTI FAMILY',
--						'APARTMENT: LOW RISE (BUILT SINCE 1960)'
--						) 
--						THEN 'Residential'
--		WHEN LandUse in ('CHURCH',
--						'VACANT COMMERCIAL LAND',
--						'PARKING LOT',
--						'RESTAURANT/CAFETERIA',
--						'NON-PROFIT CHARITABLE SERVICE',
--						'OFFICE BLDG (ONE OR TWO STORIES)',
--						'TERMINAL/DISTRIBUTION WAREHOUSE',
--						'DAY CARE CENTER',
--						'NIGHTCLUB/LOUNGE',
--						'CLUB/UNION HALL/LODGE',
--						'CONVENIENCE MARKET WITHOUT GAS',
--						'METRO OTHER THAN OFC, SCHOOL,HOSP, OR PARK',
--						'STRIP SHOPPING CENTER',
--						'LIGHT MANUFACTURING',
--						'MORTUARY/CEMETERY',
--						'SMALL SERVICE SHOP',
--						'ONE STORY GENERAL RETAIL STORE'
--						)
--						THEN 'Commercial'
--		ELSE 'Land'
--	END;

/*
Create a view that excludes records that contain a LegalReference that appears multiple times with the same SalePrice
*/
CREATE VIEW NashvilleHousingUniqueSalePrice AS
SELECT *
FROM NashvilleHousing
WHERE LegalReference not in (
	SELECT LegalReference
	FROM NashvilleHousing
	GROUP BY LegalReference
	HAVING COUNT(LegalReference) > 1 and COUNT(DISTINCT SalePrice) = 1
	)
GO;

Select *
FROM NashvilleHousingUniqueSalePrice;