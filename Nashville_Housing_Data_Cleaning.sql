-- Standardize Date fromat by removing the time on the end

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing  --First Create a new column
ADD SaleDateFormatted Date;

UPDATE Nashville_Housing  -- Then update the new column we created above with the formatted date from SaleDate
SET SaleDateFormatted = CONVERT(Date, SaleDate)

SELECT SaleDateFormatted   --- Confirm if the change was effected
FROM Nashville_Housing;


--2 Populate Property Address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

SELECT PropertyAddress   -- Confirm change was effected
FROM Nashville_Housing
WHERE PropertyAddress IS NULL;

--Breaking Address into individual columns (Address, City and State)
SELECT PropertyAddress  
FROM Nashville_Housing

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM Nashville_Housing


ALTER TABLE Nashville_Housing  
ADD PropertyAddressSplitted Nvarchar(255)

UPDATE Nashville_Housing  
SET PropertyAddressSplitted = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing  
ADD PropertyCitySplitted Nvarchar(255)

UPDATE Nashville_Housing  
SET PropertyCitySplitted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress));

SELECT *  --- Check if change was effected
FROM Nashville_Housing

--- Owner Address 
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing  
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Nashville_Housing  
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing  
ADD OwnerSplitCity Nvarchar(255)

UPDATE Nashville_Housing  
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing  
ADD OwnerSplitState Nvarchar(255)

UPDATE Nashville_Housing  
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--- Making the Values in Sold as Vacant consistent (Y/N to Yes/No)

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Nashville_Housing;

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;

-- Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
	   ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueId
					) AS row_num
FROM Nashville_Housing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--- Deleting Unused columns
ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate, PropertyAddress, TaxDistrict, OwnerAddress


SELECT *
FROM Nashville_Housing