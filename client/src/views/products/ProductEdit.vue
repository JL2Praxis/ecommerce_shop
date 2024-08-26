<script setup lang="ts">
import { watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ButtonType, ProductStatusType } from '@/_types/types'
import ProductForm from '@/components/product_form/ProductForm.vue'
import ActionButton from '@/components/button/ActionButton.vue'
import useProducts from '@/composables/useProducts'

const route = useRoute()
const router = useRouter()

const id = route.params.id as string

const {
  product,
  formData,
  handleFetchProduct,
  updateProduct
} = useProducts()

const handleSubmit = async (status: ProductStatusType): Promise<void> => {
  formData.value.status = status
  const success = await updateProduct({
    id,
    ...formData.value
  })

  if (success) {
    console.log('Successfully updated product')
    router.push({ name: 'Products' })
  } else {
    console.log('Failed to update product')
  }
}

const buttons: ButtonType[] = [
  { title: 'Cancel', type: 'normal', handler: () => router.push({ name: 'Products' }) },
  { title: 'Save as Draft', type: 'accent', handler: () => handleSubmit('unpublished') },
  { title: 'Publish', type: 'success', handler: () => handleSubmit('published') }
]

watch(
  () => id,
  () => handleFetchProduct()
)

onMounted(() => {
  handleFetchProduct()
})
</script>
<template>
  <div class="product-edit">
    <div class="product-edit-header">
      <div class="product-edit-header-left">
        <v-icon
          name="pr-arrow-left"
          class="product-edit-header-icon"
          @click="() => $router.push({ name: 'Products' })"
        />
        <h6 class="product-edit-header-title">{{ product.name }}</h6>
      </div>
      <div class="product-edit-header-right">
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
      :show-actions="true"
      :initial-form="formData"
      @update="(data) => { formData = data }"
    />
  </div>
</template>
<style lang="scss">
.product-edit {
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
