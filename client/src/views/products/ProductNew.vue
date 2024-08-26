<script setup lang="ts">
import { useRouter } from 'vue-router'
import { ButtonType, ProductStatusType } from '@/_types/types'
import useProducts from '@/composables/useProducts'
import ProductForm from '@/components/product_form/ProductForm.vue'
import ActionButton from '@/components/button/ActionButton.vue'

const router = useRouter()

const {
  formData,
  createProduct
} = useProducts()

const handleSubmit = async (status: ProductStatusType): Promise<void> => {
  formData.value.status = status
  const success = await createProduct(formData.value)

  if (success) {
    console.log('Successfully created product')
    router.push({ name: 'Products' })
  } else {
    console.log('Failed to create product')
  }
}

// TODO: Create button dropdown to for cleaner look
const buttons: ButtonType[] = [
  { title: 'Cancel', type: 'normal', handler: () => router.push({ name: 'Products' }) },
  { title: 'Save as Draft', type: 'accent', handler: () => handleSubmit('unpublished') },
  { title: 'Publish', type: 'success', handler: () => handleSubmit('published') }
]
</script>
<template>
  <div class="product-new">
    <div class="product-new-header">
      <div class="product-new-header-left">
        <v-icon
          name="pr-arrow-left"
          class="product-new-header-icon"
          @click="() => $router.push({ name: 'Products' })"
        />
        <h6 class="product-new-header-title">New Product</h6>
      </div>
      <div class="product-new-header-right">
        <ActionButton
          v-for="button in buttons"
          :key="button.title"
          :title="button.title"
          :type="button.type"
          :icon="button.icon"
          @click="button.handler"
        />
      </div>
    </div>
    <ProductForm
      :initial-form="formData"
    />
  </div>
</template>
<style lang="scss">
.product-new {
  width: 100%;
  margin: 1.25rem;
  &-header {
    @include row-between;
    &-icon {
      cursor: pointer;
    }
    &-title {
      @include font-medium;
      @include font-14;
    }
    &-left {
      @include row;
      gap: .375rem;
      align-items: center;
    }
    &-right {
      @include row;
      gap: .375rem;
      align-items: center;
    }
  }
}
</style>
