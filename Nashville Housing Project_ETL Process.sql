SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolioproject].[dbo].[NeshvilleHousing]

  SELECT* 
  FROM Portfolioproject..NeshvilleHousing
  
  --Standarize Date Format
  SELECT SaleDate, CONVERT(Date,SaleDate)
  FROM Portfolioproject..NeshvilleHousing

  UPDATE Portfolioproject..NeshvilleHousing
  SET SaleDate = CONVERT(Date,SaleDate)

  --UPDATE query did not work, therefore creating new column and will drop old one later 
  ALTER TABLE Portfolioproject..NeshvilleHousing
  ADD SaleDateConverted DATE
  
  UPDATE Portfolioproject..NeshvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate)





  --Populate Property Address data
  SELECT *
  FROM Portfolioproject..NeshvilleHousing
  ORDER BY ParcelID
  --WHERE PropertyAddress is null

  --Trying to find NULL value and which value to replace them with
  SELECT a.[UniqueID ],a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM Portfolioproject..NeshvilleHousing a
  JOIN Portfolioproject..NeshvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is null

  --updating what I found
 UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioproject..NeshvilleHousing a
  JOIN Portfolioproject..NeshvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null







--Breaking out Address into Indivisual Columns (Adress, City, State)

SELECT PropertyAddress
  FROM Portfolioproject..NeshvilleHousing

--identify that various type of value exists
SELECT* 
FROM Portfolioproject..NeshvilleHousing
WHERE PropertyAddress not like '%NASHVILLE'

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as City
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as State
FROM 
Portfolioproject..NeshvilleHousing

ALTER TABLE Portfolioproject..NeshvilleHousing
ADD PropertySplitCity Nvarchar(255)

ALTER TABLE Portfolioproject..NeshvilleHousing
ADD PropertySplitState Nvarchar(255)

 UPDATE Portfolioproject..NeshvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

  UPDATE Portfolioproject..NeshvilleHousing
  SET PropertySplitState = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

  --spliting Owneraddres
SELECT OwnerAddress
FROM Portfolioproject..NeshvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) AS Adress
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) AS States
FROM Portfolioproject..NeshvilleHousing

ALTER TABLE Portfolioproject..NeshvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE Portfolioproject..NeshvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE Portfolioproject..NeshvilleHousing
ADD OwnerSplitState Nvarchar(255)

 UPDATE Portfolioproject..NeshvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

  UPDATE Portfolioproject..NeshvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

  UPDATE Portfolioproject..NeshvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)





 --Change Y and N to Yes and No in "Sold as Vacant" field
 SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
  FROM Portfolioproject..NeshvilleHousing
  GROUP BY SoldAsVacant

 SELECT 
 SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END as NewRule
 FROM Portfolioproject..NeshvilleHousing

 UPDATE Portfolioproject..NeshvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
 FROM Portfolioproject..NeshvilleHousing



 --Remove Duplicates
 WITH RownumCTE AS
 (
 SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS rownum
 FROM Portfolioproject..NeshvilleHousing
 )
 --DELETE
 SELECT *
 FROM RownumCTE
 WHERE rownum>1

 --DELETE Unused Columns
SELECT* 
  FROM Portfolioproject..NeshvilleHousing

ALTER TABLE Portfolioproject..NeshvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, propertyAddress, SaleDate