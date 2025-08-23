/*
  Warnings:

  - A unique constraint covering the columns `[restaurantCode]` on the table `Restaurant` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "public"."Restaurant" ADD COLUMN     "restaurantCode" VARCHAR(7);

-- AlterTable
ALTER TABLE "public"."RestaurantTeam" ADD COLUMN     "codeExpiresAt" TIMESTAMP(3),
ADD COLUMN     "email" VARCHAR(255),
ADD COLUMN     "emailVerificationCode" VARCHAR(6),
ADD COLUMN     "emailVerified" BOOLEAN NOT NULL DEFAULT false;

-- CreateIndex
CREATE UNIQUE INDEX "Restaurant_restaurantCode_key" ON "public"."Restaurant"("restaurantCode");
